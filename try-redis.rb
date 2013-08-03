#!/usr/bin/env ruby

require 'logger'
require 'bundler'
Bundler.require

require_relative 'namespace_tools'

REDIS_HOST = 'localhost' unless defined?(REDIS_HOST)
REDIS_PORT = 6379 unless defined?(REDIS_PORT)

def production?
  ENV['RACK_ENV'] == 'production'
end

def development?
  ENV['RACK_ENV'] == 'development'
end


class TryRedis < Sinatra::Base
  #see the logging for development mode
  configure :development do
    enable  :logging
    disable :dump_errors
  end

  enable :sessions
  enable :static

  set :public_folder, "public"

  get("/")          { haml :index }
  get("/style.css") { sass :style }

  get("/eval") do
    if !params["session_id"].nil? && params["session_id"] != "null"
      @session_id = params["session_id"].to_s
    else
      @session_id = session["session_id"].to_s
    end

    evaluate_redis(params["command"]).merge(:session_id => @session_id).to_json
  end

  include NamespaceTools

  def internal_command(command, *args)
    case command.downcase
    when "namespace"     then namespace
    when "help"          then help args.first
    when "tutorial"      then tutorial :reset
    when /prev|previous/ then tutorial :previous
    when "next"          then tutorial :next
    when /^t(\d+)/       then tutorial $1
    end
  end

  def evaluate_redis(command)
    # Attempt to parse the given command string.
    argv =
      begin
        shellsplit(command.to_s)
      rescue Exception => e
        STDERR.puts e.message
        e.backtrace.each {|bt| STDERR.puts bt}
        return { "error" => e.message }
      end
    return { "error" => "No command received." } unless argv[0]

    # Test if the command is an internal TryRedis command.
    internal_result = internal_command(*argv)
    return { "notification" => internal_result } if internal_result

    begin
      { "response" => execute_redis(argv) }
    rescue Exception => e
      if production?
        STDERR.puts e.message
        e.backtrace.each {|bt| STDERR.puts bt}
      end
      { "error" => "(error) #{e.message}" }
    end
  end

  def namespace
    @session_id
  end

  def execute_redis(argv)
    # Apply the current namespace to any fields that need it.
    argv = parse_command(namespace, *argv)

    # If command parser finds an error, return it
    raise argv[:error] if argv.kind_of?(Hash) && argv[:error]

    # Issue the default help text if the command was not recognized.
    raise "I'm sorry, I don't recognize that command.  #{help}" unless argv.kind_of? Array

    if (err=throttle_commands(argv))
      return err
    end

    # Connect to the Redis server.
    raw_redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :logger => Logger.new(File.join(File.dirname(__FILE__),'log','redis.log')))
    redis = Redis::Namespace.new namespace, redis: raw_redis

    if (result = bypass(redis, raw_redis, argv))
      result
    else
      # Send the command to Redis.
      result = redis.send(*argv)

      if INTEGER_COMMANDS.include?(argv[0])
        result = "(integer) #{result}"
      else
        if FLATTEN_COMMANDS.include?(argv[0])
          result = result.flatten
        end

        result = to_redis_output result, argv[0], argv[1]
      end

      result
    end
  ensure
    begin
      # Disconnect from the server.
      redis.quit if redis
    rescue Exception => e
      STDERR.puts e.message
      e.backtrace.each {|bt| STDERR.puts bt}
    end
  end

  def bypass(redis, raw_redis, argv)
    queue = "transactions-#{namespace}"

    if argv.first == "multi"
      raw_redis.del queue
      raw_redis.rpush queue, 'multi'
      return "OK"
    elsif raw_redis.llen(queue).to_i >= 1
      case argv.first
      when 'discard'
        raw_redis.del(queue)
        'OK'
      when 'exec'
        # First will always be multi
        commands = raw_redis.lrange(queue, 1, -1)
        raw_redis.del(queue)

        redis.multi
        commands.map do |c|
          cmd = JSON.parse(c)
          redis.send(*cmd)
        end

        to_redis_output redis.exec, 'exec'
      else
        raw_redis.rpush queue, argv.to_json
        'QUEUED'
      end
    elsif %w(discard exec).include? argv.first
      raise "ERR #{argv.first.upcase} without MULTI"
    end
  end

  def help(keyword = "")
    helpdocs[keyword.to_s.downcase]
  end

  def helpdocs
    return @helpdocs if @helpdocs

    raw_docs =
      Dir["redis-doc/*.markdown"].map do |filename|
        command = filename.scan(/redis-doc\/(.*).markdown/).first.first
        doc = file_to_html(filename)

        [ command, doc ]
      end

    cmds = raw_docs.map {|c, d| "<a href=\"#help\">#{c.upcase}</a>"}.sort.join(", ")
    raw_docs << [ "", "Please type HELP for one of these commands: " + cmds ]

    @helpdocs ||= Hash[*raw_docs.flatten]
  end

  def tutorial(index)
    case index
    when :reset
      tutorial 1
    when :previous
      tutorial session[:tutorial].to_i - 1
    when :next
      tutorial session[:tutorial].to_i + 1
    else
      index = index.to_i
      index = 0 unless tutorialdocs[index]

      session[:tutorial] = index
      doc = tutorialdocs[index]

      if (1 ... tutorialdocs.count - 1).include? index
        doc += '<p class="tutorial_next">Type <a href="#run">NEXT</a> to continue the tutorial.</p>'
      end

      doc
    end
  end

  def tutorialdocs
    @tutorialdocs ||=
      Dir["tutorial/*.markdown"].sort.map do |filename|
        file_to_html(filename)
      end
  end

  def file_to_html(filename)
    RDiscount.new(File.read(filename)).to_html
  end
end

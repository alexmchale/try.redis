#!/usr/bin/env ruby

require "rubygems"
require "sinatra/base"
require "haml"
require "sass"
require "json"
require "redis"
require "shellwords"
require "logger"
require "rdiscount"
require "andand"

# We want all commands to go directly to redis, bypassing any
# of the different formatting that redis-rb will do.
class Redis
  remove_method :set
end

module NamespaceTools
  def namespace_input(ns, command, *args)
    case command.to_s.downcase

    when "exists", "del", "type", "keys", "ttl", "set", "get", "getset",
         "setnx", "incr", "incrby", "decr", "decrby", "rpush", "lpush",
         "llen", "lrange", "ltrim", "lindex", "lset", "lrem", "lpop", "rpop",
         "sadd", "srem", "spop", "scard", "sismember", "smembers", "srandmember",
         "zadd", "zrem", "zincrby", "zrange", "zrevrange", "zrangebyscore",
         "zcard", "zscore", "zremrangebyscore", "expire", "expireat"

      # Only the first argument is a key.

      head = add_namespace(ns, args.first)
      tail = args[1, args.length - 1] || []

      [ command, head, *tail ]

    when "smove"

      # The first two parmeters are keys.

      result = [ command ]

      args.each_with_index do |arg, i|
        result << (i == 0 || i == 1) ? add_namespace(ns, arg) : arg
      end

      result

    when "sinterstore", "sunionstore", "sdiffstore"

      # All arguments except the first are keys.

      result = [ command ]

      args.each_with_index do |arg, i|
        result << (i != 0) ? add_namespace(ns, arg) : arg
      end

      result

    when "mget", "rpoplpush", "sinter", "sunion", "sdiff"

      # All arguments are keys.

      keys = add_namespace(ns, args)

      [ command, *keys ]

    when "mset", "msetnx"

      # Every other argument is a key, starting with the first.

      hash1 = Hash[*args]
      hash2 = {}

      hash1.each do |k, v|
        hash2[add_namespace(ns, k)] = hash1.delete(k)
      end

      [ command, hash2 ]

    when "sort"

      return [] if args.count == 0

      key = add_namespace(ns, args.shift)
      parms = {}

      while keyword = args.shift.andand.downcase
        case keyword
        when "by", "get", "store"
          k = keyword.intern
          v = add_namespace(ns, args.shift)

          parms[k] = v
        when "limit"
          parms[:limit] = [ args.shift.to_i, args.shift.to_i ]
        when "asc", "desc", "alpha"
          parms[:order].andand << " "
          parms[:order] ||= ""
          parms[:order] << keyword
        end
      end

      [ command, key, parms ]

    end
  end

  def denamespace_output(namespace, command, result)
    case command.to_s.downcase

    when "keys"
      remove_namespace namespace, result

    else
      result

    end
  end

  def add_namespace(namespace, key)
    return key unless namespace

    case key
    when String then "#{namespace}:#{key}"
    when Array  then key.map {|k| add_namespace(namespace, k)}
    end
  end

  def remove_namespace(namespace, key)
    return key unless namespace

    case key
    when String then key.gsub(/^#{namespace}:/, "")
    when Array  then key.map {|k| remove_namespace(namespace, k)}
    end
  end
end

class TryRedis < Sinatra::Base
  enable :sessions
  enable :static

  set :public, "public"

  get("/")          { haml :index }
  get("/style.css") { sass :style }
  get("/eval")      { evaluate_redis(params["command"]).to_json }

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
        Shellwords.shellwords(command.to_s)
      rescue Exception => e
        STDERR.puts e.message
        e.backtrace.each {|bt| STDERR.puts bt}
        return { error: e.message }
      end
    return { error: "No command received." } unless argv[0]

    # Test if the command is an internal TryRedis command.
    internal_result = internal_command(*argv)
    return { notification: internal_result } if internal_result

    begin
      { response: execute_redis(argv) }
    rescue Exception => e
      STDERR.puts e.message
      e.backtrace.each {|bt| STDERR.puts bt}
      { error: e.message }
    end
  end

  def namespace
    session[:namespace] ||= Digest::SHA1.hexdigest(rand(2 ** 256).to_s)
  end

  def execute_redis(argv)
    # Connect to the Redis server.
    redis = Redis.new(:logger => Logger.new(STDOUT))

    # Apply the current namespace to any fields that need it.
    argv = namespace_input(namespace, *argv)

    # Issue the default help text if the command was not recognized.
    raise "I'm sorry, I don't recognize that command.  #{help}" unless argv

    # Fix up any commands that need fixing.
    result = redis.send(*argv)

    # Remove the namespace from any commands that return a key.
    denamespace_output namespace, argv.first, result
  ensure
    begin
      # Disconnect from the server.
      redis.quit
    rescue Exception => e
      STDERR.puts e.message
      e.backtrace.each {|bt| STDERR.puts bt}
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
        doc = RDiscount.new(File.read(filename)).to_html

        [ command, doc ]
      end

    cmds = raw_docs.map {|c, d| c.upcase}.sort.join(", ")
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
        doc += '<p class="tutorial_next">Type NEXT to continue the tutorial.</p>'
      end

      doc
    end
  end

  def tutorialdocs
    @tutorialdocs ||=
      Dir["tutorial/*.markdown"].sort.map do |filename|
        RDiscount.new(File.read(filename)).to_html
      end
  end
end

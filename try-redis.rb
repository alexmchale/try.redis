#!/usr/bin/env ruby

require "rubygems"
require "sinatra/base"
require "haml"
require "sass"
require "json"
require "redis"
require "shellwords"
require "logger"

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
         "zcard", "zscore", "zremrangebyscore", "sort", "expire", "expireat"

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

    when "keys"

      args

    else

      raise "Invalid command."

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

  def internal_command(argv)
    case argv.first.downcase
    when "namespace" then namespace
    end
  end

  def evaluate_redis(command)
    argv =
      begin
        Shellwords.shellwords(command.to_s)
      rescue Exception => e
        return { error: e.message }
      end
    return { error: "No command received." } unless argv[0]

    internal_result = internal_command(argv)
    return { response: internal_result } if internal_result

    begin
      {
        response: execute_redis(argv)
      }
    rescue Exception => e
      puts e.message
      e.backtrace.each {|l| puts l}

      {
        error: e.message
      }
    end
  end

  def namespace
    session[:namespace] ||= Digest::SHA1.hexdigest(rand(2 ** 256).to_s)
  end

  def execute_redis(argv)
    # Apply the current namespace to any fields that need it.
    argv = namespace_input(namespace, *argv)

    # Fix up any commands that need fixing.
    result = redis.send(*argv)

    # Remove the namespace from any commands that return a key.
    denamespace_output namespace, argv.first, result
  end

  def redis
    $redis ||= Redis.new :logger => Logger.new(STDOUT)
  end
end

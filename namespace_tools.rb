# encoding: utf-8

module NamespaceTools
  ALLOWED_COMMANDS = %w[
    append bitcount bitop echo getbit getrange hmget hsetnx incrbyfloat
    hincrbyfloat decr decrby del discard exec linsert lpushx persist pexpire
    pexpireat ping pttl psetex rpushx setbit setex setrange strlen time zcount
    zrank zremrangebyrank zrevrangebyscore zrevrank exists expire expireat get
    getset hdel hexists hget hgetall hincrby hkeys hlen hmset hset hvals incr
    incrby info keys lindex llen lpop lpush lrange lrem lset ltrim mget mset
    msetnx multi rename renamenx rpop rpoplpush rpush sadd scard sdiff
    sdiffstore set setnx sinter sinterstore sismember smembers smove sort spop
    srandmember srem sunion sunionstore ttl type zadd zcard zincrby zrange
    zrangebyscore zrem zremrangebyscore zrevrange zscore
  ]

  def namespace_input(ns, command, *args)
    command = command.to_s.downcase


    if ALLOWED_COMMANDS.include?(command)
      case command
      when "strlen"
        # Manually namespace this, redis-rb does not know it.
        key = add_namespace(ns, args.shift)
        return [ command, key ]
      when "zadd", "sadd", "zrem", "srem"
        return [ command, args.shift, args ]
      when "sort"
        return [] if args.empty?

        key    = args.shift
        params = {}

        while keyword = args.shift.andand.downcase
          case keyword
          when "by", "get", "store"
            k = keyword.intern
            params[k] = args.shift
          when "limit"
            params[:limit] = [ args.shift.to_i, args.shift.to_i ]
          when "asc", "desc", "alpha"
            params[:order].andand << " "
            params[:order] ||= ""
            params[:order] << keyword
          end
        end

        return [ command, key, params ]
      when "zrange", "zrevrange"
        # Only the first argument is a key, but special argument at the end.

        head = args.first
        tail = args[1..-1] || []
        options = {}

        if tail.last.andand.downcase == "withscores"
          tail.pop
          options[:withscores] = true
        end

        return [ command, head, *tail, options ]
      when "zrangebyscore"
        # Only the first argument is a key, but special arguments at the end.

        head = args.shift

        tail = []
        options = {}
        while keyword = args.shift
          case keyword.downcase
          when "limit"
            options[:limit] = [ args.shift.to_i, args.shift.to_i ]
          when "withscores"
            options[:withscores] = true
          else
            tail << keyword
          end
        end

        return [ command, head, *tail, options ]
      end

      [command, *args]
    end
  end

  def add_namespace(namespace, key)
    return key unless namespace

    case key
    when String then "#{namespace}:#{key}"
    when Array  then key.map {|k| add_namespace(namespace, k)}
    end
  end

end

# encoding: utf-8

ENV['RACK_ENV'] = 'test'
require 'bundler'
Bundler.require(:default, :test)

# Taken from redis-rb
class RedisVersion

  include Comparable

  attr :parts

  def initialize(v)
    case v
    when RedisVersion
      @parts = v.parts
    else
      @parts = v.to_s.split(".")
    end
  end

  def <=>(other)
    other = RedisVersion.new(other)
    length = [self.parts.length, other.parts.length].max
    length.times do |i|
      a, b = self.parts[i], other.parts[i]

      return -1 if a.nil?
      return +1 if b.nil?
      return a.to_i <=> b.to_i if a != b
    end

    0
  end
end

def redis_version
  RedisVersion.new Redis.new.info['redis_version']
end

def target_version(target)
  if redis_version < target
    skip("Requires Redis > #{target}") if respond_to?(:skip)
  else
    yield
  end
end



require_relative '../try-redis'

require 'rubygems'

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']

require "./try-redis.rb"

log = ::File.new(::File.join(::File.dirname(__FILE__),'log','sinatra.log'), "a")

def production?
  ENV['RACK_ENV'] == 'production'
end

def development?
  ENV['RACK_ENV'] == 'development'
end

if production?
  STDOUT.reopen(log)
  STDERR.reopen(log)
end

use Rack::Static, :urls => %w( /css /images /javascripts ), :root => "public"

run TryRedis

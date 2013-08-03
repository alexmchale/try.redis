require 'rubygems'

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']

require "./try-redis.rb"

use Rack::Static, :urls => %w( /css /images /javascripts ), :root => "public"

run TryRedis

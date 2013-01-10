require 'rubygems'
require 'bundler'

Bundler.require

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']

require "./try-redis.rb"

log = ::File.new(::File.join(::File.dirname(__FILE__),'log','sinatra.log'), "a")

STDOUT.reopen(log)
STDERR.reopen(log)

use Rack::Static, :urls => %w( /css /images /javascripts ), :root => "public"

run TryRedis

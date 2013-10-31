# encoding: utf-8

ENV['RACK_ENV'] = 'test'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'

require_relative '../try-redis'

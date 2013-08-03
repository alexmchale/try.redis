# encoding: utf-8

require_relative 'helper'

class TestTryRedis < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    r = Redis.new
    r.flushall
  end

  def app
    TryRedis
  end

  def command arg
    get "/eval?command=#{CGI.escape arg}"
    assert last_response.ok?
  end

  def response_was matcher
    assert_match matcher, last_response.body
  end

  def test_homepage
    get '/'
    assert last_response.ok?
    assert_match /Try Redis/, last_response.body
  end

  def test_eval_returns_set_value
    command "get foo"
    assert_match /{"response":"\(nil\)"/, last_response.body

    command "set foo bar"
    assert_match /{"response":"OK"/, last_response.body

    command "get foo"
    assert_match /{"response":"\\"bar\\""/, last_response.body
  end

  def test_eval_returns_argument_error
    command "keys"
    response_was /"\(error\) ERR wrong number of arguments for 'keys' command"/
  end

  def test_eval_returns_error_for_unknown
    command "unknown"
    response_was /\(error\) I'm sorry, I don't recognize that command./
  end

  def test_eval_responds_to_help
    command "help"
    response_was /{"notification":"Please type HELP for one of these commands:/
  end

  def test_eval_responds_to_tutorial
    command "tutorial"
    response_was /{"notification":"<p>Redis is what is called a key-value store/
  end

  def test_eval_responds_to_prev
    command "previous"
    response_was /{"notification":"<p>That wraps up the <em>Try Redis<\/em> tutorial./
  end

  def test_eval_responds_to_next
    command "next"
    response_was /{"notification":"<p>Redis is what is called a key-value store/
  end

  def test_eval_responds_to_tutorial_id
    command "t2"
    response_was /{"notification":"<p>Other common operations provided/
  end

  def test_eval_responds_to_namespace
    command "namespace"
    response_was /{"notification":"[a-f0-9]{64}/
  end

  def test_transaction_works_as_expected
    command "multi"
    response_was /{"response":"OK"/

    command "ping"
    response_was /{"response":"QUEUED"/

    command "exec"
    response_was /{"response":"1\) \\\"PONG\\\"/
  end
end

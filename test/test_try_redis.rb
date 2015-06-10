# encoding: utf-8

require_relative 'helper'

class TestTryRedis < MiniTest::Test
  include Rack::Test::Methods

  def setup
    port = ENV['REDIS_PORT'] || 6379
    host = ENV['REDIS_HOST'] || 'localhost'
    @r = Redis.new host: host, port: port
    @r.flushall
  end

  def app
    TryRedis
  end

  def set_session session_id
    @session_id = session_id
  end

  # Helper commands
  def command arg, session_id=nil
    session_id ||= @session_id if @session_id
    url = "/eval?command=#{CGI.escape arg}"
    url << "&session_id=#{session_id}" if session_id
    get url
    assert last_response.ok?
  end

  def response_was matcher
    assert_match matcher, last_response.body
  end

  def body_was key, matcher
    json = JSON.parse last_response.body
    assert_match matcher, json[key.to_s]
  end

  def command_with_body comm, args={}
    command comm

    args.each do |k,v|
      body_was k, v
    end

    if args[:error].nil?
      json = JSON.parse last_response.body
      assert_equal nil, json['error']
    end
  end
  # Helper commands end

  def test_homepage
    get '/'
    assert last_response.ok?
    assert_match /Try Redis/, last_response.body
  end

  def test_eval_returns_set_value
    command "get foo"
    body_was :response, "(nil)"

    command "set foo bar"
    body_was :response, "OK"

    command "get foo"
    body_was :response, '"bar"'
  end

  def test_eval_returns_argument_error
    command "keys"
    body_was :error, "ERR wrong number of arguments for 'keys' command"
  end

  def test_eval_returns_error_for_unknown
    command "unknown"
    body_was :error, "I'm sorry, I don't recognize that command."
  end

  def test_eval_responds_to_help
    command "help"
    body_was :notification, "Please type HELP for one of these commands:"

    command "help set"
    body_was :notification,  "<h1>SET key value"
  end

  def test_eval_responds_to_help_subsection
    command "help @string"
    body_was :notification, "<strong>"
  end

  def test_eval_responds_to_help_missing_subsection
    command "help @foo"
    body_was :notification, "No help for this group"
  end

  def test_eval_responds_to_tutorial
    command "tutorial"
    body_was :notification, "<p>Redis is what is called a key-value store"
  end

  def test_eval_responds_to_prev
    command "previous"
    body_was :notification, "<p>That wraps up the <em>Try Redis</em> tutorial."
  end

  def test_eval_responds_to_next
    command "next"
    response_was /{"notification":"<p>Redis is what is called a key-value store/
    body_was :notification, "<p>Redis is what is called a key-value store"
  end

  def test_eval_responds_to_tutorial_id
    command "t2"
    body_was :notification, "<p>Other common operations provided"
  end

  def test_eval_responds_to_namespace
    command "namespace"
    body_was :notification,  /^[a-f0-9]{64}$/
  end

  def test_transaction_works_as_expected
    command "multi"
    body_was :response, "OK"

    command "ping"
    body_was :response, "QUEUED"

    command "exec"
    body_was :response, "1) \"PONG\""
  end

  def test_extended_set
    session = "extend_set"

    key = "foo"
    val = "bar"
    exp = "bar"
    command "set #{key} #{val}", session
    body_was :response, "OK"
    assert_equal exp, @r.get("#{session}:#{key}")

    key = "foo"
    val = "next-val"
    exp = "bar"
    command "set #{key} #{val} nx", session
    body_was :response, "(nil)"
    assert_equal exp, @r.get("#{session}:#{key}")

    key = "foo"
    val = "next-val"
    exp = "next-val"
    command "set #{key} #{val} xx", session
    body_was :response, "OK"
    assert_equal exp, @r.get("#{session}:#{key}")

    key = "non-exist"
    val = "bar"
    exp = "bar"
    command "set #{key} #{val} nx", session
    body_was :response, "OK"
    assert_equal exp, @r.get("#{session}:#{key}")

    key = "non-exist2"
    val = "bar"
    exp = nil
    command "set #{key} #{val} xx", session
    body_was :response, "(nil)"
    assert_equal exp, @r.get("#{session}:#{key}")
  end

  def test_ping
    command_with_body "ping", response: "PONG"
  end

  def test_scan
    target_version "2.7.105" do

      session = "scan"

      @r.set "#{session}:foo", "bar"
      command "scan 0", session
      body_was :response, /1\) \"0\"\n2\) 1\) \"scan:foo\"/
    end
  end

  def test_sscan
    target_version "2.7.105" do

      session = "sscan"

      @r.sadd "#{session}:foo", ["bar", "baz", "bam"]
      command "sscan foo 0", session
      body_was :response, /1\) \"0\"\n2\) 1\) /
    end
  end

  def test_zscan
    target_version "2.7.105" do

      session = "zscan"

      @r.zadd "#{session}:foo", [0, "bar", 1, "baz", 2, "bam"]
      command "zscan foo 0", session
      body_was :response, /1\) \"0\"\n2\) 1\) \"/
    end
  end

  def test_hscan
    target_version "2.7.105" do

      session = "hscan"

      @r.hmset "#{session}:foo", ["key0", "val0", "key1", "val1", "key2", "val2"]
      command "hscan foo 0", session
      body_was :response, /1\) \"0\"\n2\) 1\) \"key/
    end
  end

  def test_command_sets_correct_key
    session = "valid-session-id"
    command "set bug issue-25", session

    assert_equal "issue-25", @r.get("#{session}:bug")
  end

  def test_command_returns_new_session
    command "set bug issue-25", "valid-session-id"
    body_was :session_id, /^valid-session-id/

    command "set bug issue-25", nil
    body_was :session_id, /^[a-zA-Z0-9]+/

    command "set bug issue-25", "null"
    body_was :session_id, /^[a-zA-Z0-9]+/

    command "set bug issue-25", ""
    body_was :session_id, /^[a-zA-Z0-9]+/
  end

  def test_bitpos_with_session_id
    target_version "2.9.11" do
      session_id = "id"
      @r.set "#{session_id}:foo", "a"

      command "bitpos foo 1", session_id

      body_was :session_id, session_id
      body_was :response, "(integer) 1"
    end
  end

  def test_bitpos_empty
    target_version "2.9.11" do
      command_with_body "bitpos foo 0", response: "(integer) 0"
      command_with_body "bitpos foo 1", response: "(integer) -1"
    end
  end

  def test_bitpos_notempty
    target_version "2.9.11" do
      set_session "bitpos"

      @r.set "bitpos:foo", "\xff\xf0\x00"
      command_with_body "bitpos foo 0", response: "(integer) 12"

      @r.set "bitpos:foo", "\x00\x0f\x00"
      command_with_body "bitpos foo 1", response: "(integer) 12"
    end
  end

  def test_bitpos_with_positions
    target_version "2.9.11" do
      @r.set "bitpos:foo", "\xff\xff\xff"

      set_session "bitpos"
      command_with_body "bitpos foo 0", response: "(integer) 24"
      command_with_body "bitpos foo 0 0", response: "(integer) 24"
      command_with_body "bitpos foo 0 0 -1", response: "(integer) -1"
    end
  end

  def test_bitpos_one_intervals
    target_version "2.9.11" do
      @r.set "bitpos:foo", "\x00\xff\x00"

      set_session "bitpos"
      command_with_body "bitpos foo 1 0 -1", response: "(integer) 8"
      command_with_body "bitpos foo 1 1 -1", response: "(integer) 8"
      command_with_body "bitpos foo 1 2 -1", response: "(integer) -1"
      command_with_body "bitpos foo 1 2 200", response: "(integer) -1"
      command_with_body "bitpos foo 1 1 1", response: "(integer) 8"
    end
  end

  def test_bitpos_invalid_arguments
    target_version "2.9.11" do
      command_with_body "bitpos foo 2", error: /The bit argument must be /
    end
  end

  def test_bitpos_no_arguments
    target_version "2.9.11" do
      command_with_body "bitpos", error: /ERR wrong number of arguments for 'bitpos' command/
    end
  end

  def test_strlen_works
    set_session "strlen"
    @r.set "strlen:foo", "bar"
    command_with_body "strlen foo", response: "(integer) 3"
  end

  def test_pfadd_no_arguments
    target_version "2.9.11" do
      command_with_body "pfadd", error: /ERR wrong number of arguments for 'pfadd' command/
    end
  end

  def test_pfcount_no_arguments
    target_version "2.9.11" do
      command_with_body "pfcount", error: /ERR wrong number of arguments for 'pfcount' command/
    end
  end

  def test_pfadd
    target_version "2.9.11" do
      set_session "hll"

      command_with_body "pfadd hll foo bar baz", response: "(integer) 1"
      assert_equal @r.pfcount("hll:hll"), 3
    end
  end

  def test_pfcount
    target_version "2.9.11" do
      set_session "hll"

      command_with_body "pfadd hll foo bar baz", response: "(integer) 1"
      command_with_body "pfcount hll", response: "(integer) 3"
      assert_equal @r.pfcount("hll:hll"), 3
    end
  end

  def test_pfmerge_wrong_argument_count
    target_version "2.9.11" do
      command_with_body "pfmerge", error: /ERR wrong number of arguments for 'pfmerge' command/
      command_with_body "pfmerge foo", error: /ERR wrong number of arguments for 'pfmerge' command/
    end
  end

  def test_pfmerge
    target_version "2.9.11" do
      set_session "hll"

      command_with_body "pfadd hll1 foo bar zap a", response: "(integer) 1"
      command_with_body "pfadd hll2 a b c foo",     response: "(integer) 1"
      command_with_body "pfmerge hll3 hll1 hll2",   response: "OK"
      command_with_body "pfcount hll3",             response: "(integer) 6"
      assert_equal 4, @r.pfcount("hll:hll1")
      assert_equal 4, @r.pfcount("hll:hll2")
      assert_equal 6, @r.pfcount("hll:hll3")
    end
  end

  def test_lexfamily
    target_version "2.8.9" do
      set_session "lex"

      command_with_body "ZADD myzset 0 a 0 b 0 c 0 d 0 e", response: "(integer) 5"
      command_with_body "ZADD myzset 0 f 0 g", response: "(integer) 2"
      command_with_body "ZLEXCOUNT myzset - +", response: "(integer) 7"
      command_with_body "ZLEXCOUNT myzset [b [f", response: "(integer) 5"
      command_with_body "ZRANGEBYLEX myzset [b [b", response: "1) \"b\"\n"
      command_with_body "ZREMRANGEBYLEX myzset [b [d", response: "(integer) 3"
      assert_equal 4, @r.zcard("lex:myzset")

      command_with_body "zlexcount", error: /ERR wrong number of arguments for 'zlexcount' command/
      command_with_body "zlexcount a", error: /ERR wrong number of arguments for 'zlexcount' command/
      command_with_body "zlexcount a b c d", error: /ERR wrong number of arguments for 'zlexcount' command/
    end
  end
end

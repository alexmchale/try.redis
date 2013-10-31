# encoding: utf-8

require_relative 'helper'

class TestNamespaceTools < Minitest::Test
  def setup
    # Small hack to access parse_command
    NamespaceTools.__send__ :extend, NamespaceTools
  end

  # Pass 'ns' as namespace for all tests.
  def parse_command command, *args
    NamespaceTools::parse_command('ns', command, *args)
  end

  # Helper function.
  def parse_command_equal expected, to_send
    assert_equal expected, parse_command(*to_send)
  end

  def test_parse_command_unknown
    assert_equal nil, parse_command('foo', 'bar')
  end

  def test_parse_command_correct
    to_test = [
      [ ['set', 'foo', 'bar'], ['set', 'foo', 'bar'] ],
      [ ['keys', '*'],         ['keys', '*'] ],
    ]

    to_test.each do |exp, cmd|
      parse_command_equal exp, cmd
    end
  end

  def test_parse_command_incorrect
    to_test = [
      [ {error: "ERR wrong number of arguments for 'keys' command"}, ['keys'] ],
      [ {error: "ERR wrong number of arguments for 'keys' command"}, ['keys', 'one', 'two'] ]
    ]

    to_test.each do |exp, cmd|
      parse_command_equal exp, cmd
    end
  end

  def test_shellsplit
    to_test = [
      [ ["set", "foo", "bar"], "set foo bar" ],
      [ ["set", "b\\*", "bar"], "set b\\* bar" ],
      [ ["set", "foo bar", "baz"], 'set "foo bar" baz' ],
      [ ["set", "foo\\", "bar"], 'set foo\ bar' ],
    ]

    to_test.each do |exp, line|
      assert_equal exp, NamespaceTools.shellsplit(line)
    end
  end
end

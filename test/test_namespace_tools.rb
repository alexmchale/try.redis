# encoding: utf-8

require 'minitest/autorun'
require_relative '../namespace_tools'

class TestNamespaceTools < Minitest::Test
  def setup
    # Small hack to access parse_command
    NamespaceTools.__send__ :extend, NamespaceTools
  end

  def parse_command command, *args
    NamespaceTools::parse_command('ns', command, *args)
  end

  def test_parse_command_unknown
    assert_equal nil, parse_command('foo', 'bar')
  end

  def parse_command_equal expected, to_send
    assert_equal expected, parse_command(*to_send)
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
end

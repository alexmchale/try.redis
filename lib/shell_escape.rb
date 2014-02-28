# encoding: utf-8

module ShellEscape
  extend self

  UNESCAPES = {
    'a' => "\x07", 'b' => "\x08", 't' => "\x09",
    'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
    'r' => "\x0d", 'e' => "\x1b", "\\\\" => "\x5c",
    "\"" => "\x22", "'" => "\x27"
  }

  def unescape_literal(str)
    # Escape all the things
    str.gsub(/\\(?:([#{UNESCAPES.keys.join}])|u([\da-fA-F]{4}))|\\0?x([\da-fA-F]{2})/) {
      if $1
        if $1 == '\\' then '\\' else UNESCAPES[$1] end
      elsif $2 # escape \u0000 unicode
        ["#$2".hex].pack('U*')
      elsif $3 # escape \0xff or \xff
        [$3].pack('H2')
      end
    }
  end

  # Parse a command line style list of arguments that can be optionally
  # delimited by '' or "" quotes, and return it as an array of arguments.
  #
  # Strings delimited by "" are unescaped by converting escape characters
  # such as \n \x.. to their value according to the unescape_literal()
  # function.
  #
  # Example of line that this function can parse:
  #
  # "Hello World\n" other arguments 'this is a single argument'
  #
  # The above example will return an array of four strings.
  def cli_split(line)
    argv = []
    arg = ""
    inquotes = false
    pos = 0
    while pos < line.length
      char = line[pos] # Current character
      isspace = char.valid_encoding? && char =~ /\s/

      # Skip empty spaces if we are between strings
      if !inquotes && isspace
        if arg.length != 0
          argv << arg
          arg = ""
        end
        pos += 1
        next
      end

      # Append current char to string
      arg << char
      pos += 1

      if arg.length == 1 && (char == '"' || char == '\'')
        inquotes = char
      elsif arg.length > 1 && inquotes && char == inquotes
        inquotes = false
      end
    end
    # Put the last argument into the array
    argv << arg if arg.length != 0

    # We need to make some post-processing.
    # For strings delimited by '' we just strip initial and final '.
    # For strings delimited by "" we call unescape_literal().
    # This is not perfect but should be enough for redis.io interactive
    # editing.
    argv.map {|x|
      if x[0] == '"'
        unescape_literal(x[1..-2])
      elsif x[0] == '\''
        x[1..-2]
      else
        x
      end
    }
  end
end

if $0 == __FILE__
  def byte_equal a, b
    a.zip(b).all? { |(l,r)| l.bytes.to_a == r.bytes.to_a }
  end

  [
    [["foo", "bar"],  "foo bar"],
    [["foo bar"],     '"foo bar"'],
    [["\xff"],        '"\xff"'],
    [["\xff"],        "\xff"],
  ].each do |(should, line)|
    is = ShellEscape.cli_split(line)

    unless byte_equal(should, is)
      puts "expected #{should.inspect} to match #{is.inspect}"
    end
  end
end

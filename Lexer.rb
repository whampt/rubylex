# Our lexer will be used like so: `Lexer.new.tokenize("line")`,
# and will return an array of tokens (a token being a tuple of `[TOKEN_TYPE, TOKEN_VALUE]`).
# This lexer is for single lines of SimPL as provided in CS 401 Ruby assignment
require_relative 'Token'

class Lexer
  KEYWORDS = ["if","then","else","end","while","do","and","true","false"]
  OPS = ['<=','<','=','(',')']
  VOPS = %w[ + - * / ]
  attr_reader :tokens
  def initialize
    @tokens = Array.new
    @position = 0
  end

  def tokenize_line(line)
    # Advance one character at the time until you find something to parse.
    # We'll use regular expressions to scan from the current position (`i`)
    # up to the end of the line.
    i = 0 # Current character position

    while i < line.size
      chunk = line[i..-1] # [[i..-1] means from i to and including last character

      # Each of the following `if/elsif`s will test the current line chunk with
      # a regular expression. The order is important as we want to match `if`
      # as a keyword, and not a method name, we'll need to apply it first.
      #
      # First, we'll scan for names: method names and variable names, which we'll call identifiers.
      # Also scanning for special reserved keywords such as `if`, `def`
      # and `true`.
      if (id = chunk[/\A([A-Za-z]+)/, -1])
        if KEYWORDS.include?(id) # keywords will generate [:IF, "if"]
          @tokens << [Token.new(:IDENTIFIER, id)]
          i += id.size #skip what we just parsed
        else
          @tokens << [Token.new(:VAR, id)]
          i += id.size # skip what we just parsed
        end


        # Now scanning for numbers
      elsif (number = chunk[/\A([0-9]+)/, -1])
        @tokens << [Token.new(:NUMBERS, number)]
        i += number.size

        # Now scanning for variables, using letters.
      elsif (stop = chunk[/^;/])
        @tokens << [Token.new(:END, stop)]
        i += stop.size

        #checking for empty spaces
      elsif (space = chunk[/\A(\s+)/, 1])
        i += space.size

        # catches and advances past comments
      elsif (comment = chunk[/^[\/]+.*/])
        i += comment.size
        # checks for equals
      elsif (assign = chunk[/^:=/])
        @tokens << [Token.new(:ASSIGN, assign)]
        i += assign.size

      elsif (nline = chunk[/^[\n]+/])
        @tokens << [Token.new(:NLINE, nline )]
        i += assign.size
      elsif (ops = chunk[/\A(\*|\/|\+|-|:=|\(|\)|<=|<|=)/])
        if VOPS.include?(ops)
          @tokens << [Token.new(:VOPS, ops)]
          i += 1
        elsif OPS.include?(ops)
          @tokens << [Token.new(:OPS, ops)]
          i += 1
        end
      else
        i += 1
      end
    end
  end

  def tokenize(filename)
    # stop = ';'
    File.foreach(filename).with_index do |line, line_num|
      tokenize_line(line)
      @tokens << [Token.new(:NLINE, 'newline')]
      thing = tokens[-1]
      #if thing[0].value == stop
      #   puts 'ya'
      #  end
    end
    @tokens << [Token.new(:EOF, 'eof')]  #end of file character
  end

  # returns text for next sequential token
  def get_token_text
    thing = @tokens[@position]
    return thing[0].text

  end
  # returns type of the token.

  def get_token_label
    thing = @tokens[@position]
    return thing[0].label
  end
  def get_last_value
    thing = @tokens[-1]
    return thing[0].text
  end
  # consumes the current token.
  def get_next
    #  return @tokens.delete_at 0
  begin
    if @position < @tokens.size
      @position +=1
      return @tokens[@position-1]
    end
  rescue
    return false
end
end
  # checks to see if there is a next token
  def has_next
    @position < @tokens.size
  end
  # push position of the pointer to current token back one
  def push_back
    @position -= 1
  end
  # set position counter ro 0
  def start_over
    @position =0
  end

end
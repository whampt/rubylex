# requires stuff
require_relative 'Lexer'
require_relative 'Token'
require_relative 'Checker'
# calls lever on line and prints the result to the console
class SyntaxCheck

  lex = Lexer.new

  # lex.tokenize('oneLine.txt')
  lex.tokenize(ARGV[0])
  puts 'How many tokens?'
  # Check until get semicolon check correct and then move on
  i = 0
  while lex.has_next

    puts "#{i}: #{lex.get_token_label} ""#{lex.get_token_text}"
    lex.get_next
    i+=1
  end
  check = Checker.new
  lex.start_over
  if(check.program?(lex))
    puts "GOOD"
    else
    puts "ERROR"
  end
end
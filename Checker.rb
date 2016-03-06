require_relative 'lexer'
require_relative 'Token'
class Checker
  def program?(lex)
    return stmts?(lex)
  end

  def stmts?(lex)
    if !lex.has_next || lex.get_token_label==:EOF
      return true;
    end
    arr = Array.new
    #first, grab all tokens up to the first semicolon
    while lex.has_next && lex.get_token_label!=:EOF

      arr << lex.get_next
    end
    #then, check if arr is a stmt after discarding the semicolon
    lex.get_next
    return stmt?(arr) && stmts?(lex)
  end

  def stmt?(arr)
    return vexp?(arr) || iexp?(arr) || wexp?(arr)

  end

  def vexp?(arr)
    if(arr[0][0].label!=:VAR)
      return false
    elsif arr[1][0].label!=:ASSIGN
      return false
    else return addop?(arr[2..-1])
    end
  end

  def iexp?(arr)
    if(arr[0][0].text!='if')
      return false
    end
    #get the tokens between if and then
    i=1
    while(i<arr.size&&arr[i][0].text!='then')
      i+=1
    end
    if !lexp?(arr[1..i])
      return false
    end
    j=i+1 #skip the then
    while(j<arr.size&&arr[j][0].text!='else')
      j+=1
    end
    if !stmts?(new Lexer(arr[i+1..j]))
      return false
    end
    k=i+1 #skip the else
    while(k<arr.size&&arr[k][0].text!='end')
      k+=1
    end
    return stmts?(arr[j+1..k])
  end
  def wexp?(arr)
    if(arr[0][0].text!='while')
      return false
    end

    #get the tokens between while and do
    i=1
    while(i<arr.size&&arr[i][0].text!='do')
      i+=1
    end
    if !lexpr?(arr[1..i-1])
      return false
    end
    j=i+1 #skip the do
    while(j<arr.size&&arr[j][0].text!='end')
      j+=1
    end
    return stmts?(arr[i+1..j])
  end

  def addop?(arr)
    i=0
    while(i<arr.size)
      break if (arr[i][0].text=="+"||arr[i][0].text=="-")
      i+=1
    end

    if !mulop?(arr[0..i-1])
      return false
    elsif arr.size==i #reached the end of the mulop without finding more to check
      return true
    else
      return addop?(arr[i+1..-1])
    end
  end
  def mulop?(arr)
    i=0
    while(i<arr.size)
      break if (arr[i][0].text=="*"||arr[i][0].text=="/")
      i+=1
    end
    if !factor?(arr[0..i-1])
      return false
    elsif arr.size==i #reached the end of the mulop without finding more to check
      return true
    else
      return mulop?(arr[i+1..-1])
    end

  end
  def factor?(arr)
    if arr[0][0].label==:NUMBERS || arr[0][0].label==:VAR
      return true
    else
      return arr[0][0].label=='('&&arr[-1][0].label==')'&& addop?(arr[1..-2])
    end
  end

  def lexpr?(arr)
    i=0
    while(i<arr.size)
      break if (arr[i][0].text=="and")
      i+=1
    end
    if !lterm?(arr[0..i-1])
      return false
    elsif arr.size==i #reached the end of the lexpr without finding more to check
      return true
    else
      return lexpr?arr[i+1..-1]
    end
  end


  def lterm?(arr)
    if arr[0][0].text=="not"&&lfactor?(arr[1..-1])
      return true
    else
      return lfactor?(arr)
    end
  end

  def lfactor?(arr)
    return (arr.size==1&&(arr[0][0].text=="true"||arr[0][0].text=="false"))||relop?(arr)
  end

  def relop?(arr)
    i=0
    while(i<arr.size)
      break if (arr[i][0].text=="<="|| arr[i][0][0].text=="<"||arr[i][0].text=="=")
      i+=1
    end
    return addop?(arr[0..i-1])&&addop?(arr[i+1..-1])

  end
end
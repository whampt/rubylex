# token class
class Token


  def initialize( l, v)
    @label = l
    @text = v
  end

  attr_reader :label, :text
  def to_s
    " #{label} #{text} "
  end
end
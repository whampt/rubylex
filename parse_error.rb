class Parse_Error < StandardError
  def initialize(data)
    super
    @data=data
  end
end
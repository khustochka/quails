class TitleFormatter
  def initialize(str)
    @str = str
  end

  def to_html
    OneLineFormatter.apply(@str)
  end
end

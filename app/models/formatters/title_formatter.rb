class TitleFormatter
  def initialize(str)
    @str = str
  end

  def to_html
    RedCloth.new(@str, [:lite_mode]).to_html.html_safe
  end
end

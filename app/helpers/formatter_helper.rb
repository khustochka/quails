module FormatterHelper
  def format_one_line(str)
    RedCloth.new(str, [:lite_mode]).to_html.html_safe
  end
end

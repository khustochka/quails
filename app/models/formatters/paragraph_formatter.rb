class ParagraphFormatter
  def self.apply(str)
    RedCloth.new(str).to_html.html_safe
  end
end

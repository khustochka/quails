class ParagraphFormatter
  def self.apply(str)
    RedCloth.new(str).to_html
  end
end

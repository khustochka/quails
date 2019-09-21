class ParagraphFormatter
  def self.apply(str)
    Rinku.auto_link(RedCloth.new(str).to_html, :urls)
  end
end

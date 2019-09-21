module OneLineFormatter
  def self.apply(str)
    RedCloth.new(str, [:lite_mode]).to_html.html_safe
  end
end

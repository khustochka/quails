class WikiFormatter

  def initialize(text)
    @text = text
  end

  def for_site
    @strategy = SiteFormatStrategy.new(@text)
    apply
  end

  def for_lj
    @strategy = LJFormatStrategy.new(@text)
    apply
  end

  private
  def apply
    ParagraphFormatter.apply(
        @strategy.apply
    )
  end

end

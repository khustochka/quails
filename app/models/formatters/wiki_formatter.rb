class WikiFormatter

  def initialize(strategy)
    @strategy = strategy
  end

  def apply(text)
    ParagraphFormatter.apply(
        @strategy.wiki_format(text)
    )
  end

end

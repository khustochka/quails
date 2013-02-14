class WikiFormatter

  def initialize(strategy)
    @strategy = strategy
  end

  def apply
    ParagraphFormatter.apply(
        @strategy.apply
    )
  end

end

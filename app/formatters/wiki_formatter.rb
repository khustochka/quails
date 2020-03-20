class WikiFormatter

  ParagraphPipeline = HTML::Pipeline.new [
                                             HTML::Pipeline::TextileFilter,
                                             HTML::Pipeline::AutolinkFilter
                                         ]

  def initialize(text, metadata = {})
    @text = text
    @metadata = metadata
  end

  def for_site
    @strategy = SiteFormatStrategy.new(@text, @metadata)
    apply.html_safe
  end

  def for_feed
    @strategy = FeedFormatStrategy.new(@text, @metadata)
    apply.html_safe
  end

  def for_instant_articles
    @strategy = InstantArticlesFormatStrategy.new(@text, @metadata)
    apply.html_safe
  end

  def for_lj
    @strategy = LJFormatStrategy.new(@text, @metadata)
    apply
  end

  private

  def apply
    ParagraphPipeline.call(@strategy.apply)[:output].to_s
  end

end

# frozen_string_literal: true

class WikiFormatter

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
    ParagraphFormatter.apply(
        @strategy.apply
    )
  end

end

# frozen_string_literal: true

class WikiFormatter
  def initialize(text, metadata = {})
    @text = text
    @metadata = metadata
  end

  def for_site
    @strategy = FormatStrategy::Site.new(@text, @metadata)
    apply.html_safe
  end

  def for_feed
    @strategy = FormatStrategy::Feed.new(@text, @metadata)
    apply.html_safe
  end

  def for_instant_articles
    @strategy = FormatStrategy::InstantArticle.new(@text, @metadata)
    apply.html_safe
  end

  def for_lj
    @strategy = FormatStrategy::LiveJournal.new(@text, @metadata)
    apply
  end

  private

  def apply
    # TODO: if you want first to apply Textile, and then strategy formatting, do this firt:
    # post.body.gsub(/^\{\{(\^|&)[^}]+\}\}\s*$/, 'notextile. \&')
    ParagraphFormatter.apply(@strategy.apply)
  end
end

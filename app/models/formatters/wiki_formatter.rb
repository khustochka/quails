require "wiki_filter"

class WikiFormatter

  include WikiFilter

  def initialize(strategy)
    @strategy = strategy
  end

  def apply(text)
    ParagraphFormatter.apply(
        wiki_format(text)
    )
  end

  private

  def wiki_format(text)
    transform(text)
  end

end

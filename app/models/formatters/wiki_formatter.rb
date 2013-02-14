class WikiFormatter

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

    @strategy.prepare(text)

    result = text.gsub(/\[(@|#|)(?:([^\]]*?)\|)?(.*?)\]/) do |_|
      tag, word, term = $1, $2.try(:html_safe), $3
      case tag
        when '@' then
          %Q("#{word || term}":#{term})
        when '#' then
          @strategy.post_link(word, term)
        when '' then
          @strategy.species_link(word, term)
      end
    end

    result << @strategy.post_scriptum

    result
  end

end

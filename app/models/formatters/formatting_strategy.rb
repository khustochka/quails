class FormattingStrategy

  def wiki_format(text)

    prepare(text)

    result = text.gsub(/\[(@|#|)(?:([^\]]*?)\|)?(.*?)\]/) do |_|
      tag, word, term = $1, $2.try(:html_safe), $3
      case tag
        when '@' then
          %Q("#{word || term}":#{term})
        when '#' then
          post_link(word, term)
        when '' then
          species_link(word, term)
      end
    end

    result << post_scriptum

    result
  end

end

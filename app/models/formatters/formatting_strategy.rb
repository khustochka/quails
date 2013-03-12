class FormattingStrategy
  
  def initialize(text, metadata = {})
    @text = text
    @metadata = metadata
  end

  def apply

    prepare

    result = @text.gsub(/\[(@|#|)(?:([^\]]*?)\|)?(.*?)\]/) do |_|
      tag, word, term = $1, $2.try(:html_safe), $3
      case tag
        when '@' then
          if term == "lj"
            lj_user(word)
          else
            %Q("#{word || term}":#{term})
          end
        when '#' then
          post_link(word, term)
        when '' then
          species_link(word, term)
      end
    end

    result.gsub!(/([Ввр])О([рн])/, '\1о&#769;\2')

    result << post_scriptum

    result
  end

end

class FormattingStrategy

  WIKI_PREFIXES = "@|#|\\^|&"

  def initialize(text, metadata = {})
    @text = text
    @metadata = metadata
  end

  def apply

    prepare

    result = @text.gsub(/\{\{(#{WIKI_PREFIXES}|)(?:([^\}]*?)\|)?([^\}]*?)(\|en)?\}\}/) do |_|
      tag, word, term, en = $1, $2.try(:html_safe), $3, $4
      case tag
        when '@' then
          if term == "lj"
            lj_user(word)
          end
        when '#' then
          post_link(word, term)
        when '^' then
          img_link(term)
        when '&' then
          video_embed(term)
        when '' then
          if term == "en"
            term = word
            word = nil
            en = "en"
          end
          species_link(word, term.gsub("_", " "), en)
      end
    end

    result.gsub!(/([Ввр])О([рн])/, '\1о&#769;\2')

    result << post_scriptum

    result
  end

  private

  def prepare
    @posts = Hash.new do |hash, term|
      hash[term] = Post.find_by(slug: term.downcase)
    end

    sp_codes = @text.scan(/\{\{(?!#{WIKI_PREFIXES})(?:([^\}]*?)\|)?(.+?)(\|en)?\}\}/).map do |word, term|
      if term && term != "en"
        term
      else
        word
      end.sub("_", " ")
    end.uniq.compact

    # TODO: use already calculated species of the post! the rest will be ok with separate requests?
    if sp_codes.any?
      @spcs = Species.where("code IN (?) OR species.name_sci IN (?)", sp_codes, sp_codes)
      @species = @spcs.index_by(&:code_or_slug).merge(@spcs.index_by(&:name_sci))
    else
      @spcs = []
      @species = {}
    end
  end

  def only_path?
    true
  end

end

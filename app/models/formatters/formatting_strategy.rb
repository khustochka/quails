class FormattingStrategy

  WIKI_PREFIXES = "@|#|\\^|&"

  def initialize(text, metadata = {})
    @text = text
    @metadata = metadata
  end

  def apply

    prepare

    result = @text.gsub(/\{\{(#{WIKI_PREFIXES}|)(?:([^\}]*?)\|)?([^\}]*?)\}\}/) do |_|
      tag, word, term = $1, $2.try(:html_safe), $3
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
          species_link(word, term)
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

    sp_codes = @text.scan(/\{\{(?!#{WIKI_PREFIXES})(?:([^\}]*?)\|)?(.+?)\}\}/).map do |word, term|
      term || word
    end.uniq.compact

    # TODO: use already calculated species of the post! the rest will be ok with separate requests?
    if sp_codes.any?
      @spcs = Species.where("code IN (?) OR name_sci IN (?)", sp_codes, sp_codes)
      @species = @spcs.index_by(&:code).merge(@spcs.index_by(&:name_sci))
    else
      @spcs = []
      @species = {}
    end
  end

  def only_path?
    true
  end

end

class LJFormatStrategy < FormattingStrategy

  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper

  def prepare
    @posts = Hash.new do |hash, term|
      hash[term] = Post.find_by_slug(term.downcase)
    end

    sp_codes = @text.scan(/\[(?!#|@)(?:([^\]]*?)\|)?(.+?)\]/).map do |word, term|
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

  def lj_user(user)
    %Q(<lj user="#{user}">)
  end

  def post_link(word, term)
    post = @posts[term]
    post.nil? || post.lj_url.nil? ?
        word :
        %Q("#{word || post.formatted.title}":#{term})
  end

  def species_link(word, term)
    sp = @species[term]
    if sp
      %Q(<b title="#{sp.name_sci}">#{word || sp.name_sci}</b>)
      #%Q("(sp_link). #{word || sp.name_sci}":#{sp.code})
    else
      term.size > 6 ? unknown_species(word, term) : (word || term)
    end
  end

  def post_scriptum
    result = ''

    if @metadata[:images].any?
      result << "\n\n"
      @metadata[:images].each_with_index do |img, i|
        result << '<lj-cut>' if i > 0
        result << "!#{jpg_url(img)}(#{img.public_title})!\n#{img.public_title} __(#{img.species.first.name_sci})__\n\n"
      end
      result << '</lj-cut>' if @metadata[:images].size > 1
    end

    if @posts.any? || @spcs.any?
      result << "\n"

      @posts.each do |slug, post|
        result << "\n[#{slug}]#{post.lj_url}" if post && post.lj_url
      end
    end

    result
  end

end

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

  def img_link(term)
    if term =~ %r{^(https?:/)?/}
      "!#{term}!"
    else
      if image = Image.find_by_slug(term)
        %Q(!#{jpg_url(image)}([photo])!\n#{image.formatted.title} __(#{image.species.map(&:name_sci).join(', ')})__)
      end
    end
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
        result << '<lj-cut>\n\n' if i == 1
        title = img.formatted.title
        result << "!#{jpg_url(img)}(#{title})!\n#{title} __(#{img.species.map(&:name_sci).join(', ')})__\n\n"
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

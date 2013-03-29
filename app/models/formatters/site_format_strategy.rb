class SiteFormatStrategy < FormattingStrategy

  include Rails.application.routes.url_helpers
  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper
  include PublicRoutesHelper

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

    #species = Hash.new do |hash, term|
    #  hash[term] = term.size == 6 ?
    #      spcs.find { |s| s.code == term } :
    #      spcs.find { |s| s.name_sci == term.sp_humanize }
    #end

  end

  def lj_user(user)
    %Q(<span class="ljuser" style="white-space: nowrap;"><a href="http://#{user}.livejournal.com/profile" rel="nofollow"><img src="http://p-stat.livejournal.com/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="http://#{user}.livejournal.com/" rel="nofollow"><b>#{user}</b></a></span>)
  end

  def post_link(word, term)
    post = @posts[term]
    post.nil? ?
        word :
        %Q("#{word || '"%s"' % post.formatted.title}":#{term})
  end

  def img_link(term)
    if image = Image.find_by_slug(term)
      %Q("!#{jpg_url(image)}([photo])!":#{image_path(image)}\n#{image.formatted.title} __(#{image.species.map(&:name_sci).join(', ')})__)
    end
  end

  def species_link(word, term)
    sp = @species[term]
    if sp
      %Q("(sp_link). #{word || sp.name_sci}":#{sp.code})
    else
      term.size > 6 ? unknown_species(word, term) : (word || term)
    end
  end

  def post_scriptum
    result = ''
    if @posts.any? || @spcs.any?
      result << "\n"

      @posts.each do |slug, post|
        result << "\n[#{slug}]#{public_post_path(post)}" if post
      end

      @spcs.each do |sp|
        result << "\n[#{sp.code}]#{species_path(sp)}"
      end
    end

    result
  end
end

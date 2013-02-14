class SiteFormatStrategy < FormattingStrategy

  delegate :url_helpers, to: 'Rails.application.routes'
  include SpeciesHelper
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

  def post_link(word, term)
    post = @posts[term]
    post.nil? ?
        word :
        %Q("#{word || post.formatted.title}":#{term})
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
        result << "\n[#{sp.code}]#{url_helpers.species_path(sp)}"
      end
    end

    result
  end
end

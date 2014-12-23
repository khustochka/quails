class SiteFormatStrategy < FormattingStrategy
  include VideoEmbedder

  include Rails.application.routes.url_helpers
  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper
  include PublicRoutesHelper

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
    if image = Image.find_by(slug: term)
      %Q(<figure class="imageholder">
        "!#{jpg_url(image)}([photo])!":#{image_path(image)}
          <figcaption class="imagetitle"><a href="#{image_url(image, only_path: only_path?)}">#{image.formatted.title}</a></figcaption>
          </figure>
        )
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
        result << "\n[#{slug}]#{public_post_url(post, only_path: only_path?)}" if post
      end

      @spcs.each do |sp|
        result << "\n[#{sp.code}]#{localized_species_url(id: sp, only_path: only_path?)}"
      end
    end

    result
  end
end

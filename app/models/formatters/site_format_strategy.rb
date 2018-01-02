class SiteFormatStrategy < FormattingStrategy
  include VideoEmbedder

  include Rails.application.routes.url_helpers
  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include PublicRoutesHelper

  def lj_user(user)
    %Q(<span class="ljuser" style="white-space: nowrap;"><a href="https://#{user}.livejournal.com/profile" rel="nofollow"><img src="http://p-stat.livejournal.com/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="http://#{user}.livejournal.com/" rel="nofollow"><b>#{user}</b></a></span>)
  end

  def post_tag(word, term)
    post = @posts[term]
    post.nil? ?
        word :
        %Q("#{word || '"%s"' % post.decorated.title}":#{term})
  end

  def img_tag(term)
    if image = Image.find_by(slug: term)
      img_url = image_url(image, only_path: only_path?)
      %Q(<figure class="imageholder">
        "!#{jpg_url(image)}([photo])!":#{img_url}
          <figcaption class="imagetitle"><a href="#{img_url}">#{image.decorated.title}</a></figcaption>
          </figure>
        )
    end
  end

  def species_tag(word, term, en)
    sp = @species[term]
    if sp
      #str = %Q("(sp_link). #{word or (en ? sp.name_en : sp.name_sci)}":#{sp.code_or_slug})
      str = species_link(sp, word.presence || (en ? sp.name_en : sp.name_sci))
      if en && word.present?
        str << " (#{sp.name_en})"
      end
      str
    else
      term.size > 6 ? unknown_species(word, term) : (word || term)
    end
  end

  def post_scriptum
    result = ''
    if @posts.any?
      result << "\n"

      @posts.each do |slug, post|
        result << "\n[#{slug}]#{public_post_url(post, only_path: only_path?)}" if post
      end
    end

    result
  end
end

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
        %Q("#{word || '"%s"' % post.decorated.title}":#{term})
  end

  def img_link(term)
    if image = Image.find_by(slug: term)
      img_url = image_url(image, only_path: only_path?)
      %Q(<figure class="imageholder">
        "!#{jpg_url(image)}([photo])!":#{img_url}
          <figcaption class="imagetitle"><a href="#{img_url}">#{image.decorated.title}</a></figcaption>
          </figure>
        )
    end
  end

  def species_link(word, term, en)
    sp = @species[term]
    if sp
      str = %Q("(sp_link). #{word or (en ? sp.name_en : sp.name_sci)}":#{sp.code})
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

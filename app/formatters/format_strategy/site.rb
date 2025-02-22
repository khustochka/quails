# frozen_string_literal: true

module FormatStrategy
  class Site < Base
    include VideoEmbedderHelper

    include SpeciesHelper
    include ImagesHelper
    include PostsHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include PublicRoutesHelper
    include LocaleHelper

    def lj_user(user)
      %Q(<span class="ljuser" style="white-space: nowrap;"><a href="https://#{user}.livejournal.com/profile" rel="nofollow"><img src="https://l-stat.livejournal.net/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="https://#{user}.livejournal.com/" rel="nofollow"><b>#{user}</b></a></span>)
    end

    def post_tag(word, term)
      post = @posts[term]
      post.nil? ?
        word :
        %Q("#{word || '"%s"' % post.decorated.title}":#{term})
    end

    def img_tag(term)
      if (image = Image.find_by(slug: term))
        img_url = localized_image_url(id: image, locale: current_locale_prefix)
        %Q(<figure class="imageholder">
        "!#{jpg_url(image)}([photo])!":#{img_url}
          <figcaption class="imagetitle"><a href="#{img_url}" class="not-green">#{image.decorated.title}</a></figcaption>
          </figure>
        )
      end
    end

    def species_tag(word, term, en)
      # FIXME: Refactor url helpers, only_path, and especially species_link!
      sp = @species[term]
      if sp
        str = String.new species_link(sp, word.presence || (en ? sp.name_en : sp.name_sci), locale: current_locale_prefix)
        if en && word.present?
          str << " (#{sp.name_en})"
        end
        str
      else
        term.size > 6 ? unknown_species(word, term) : (word || term)
      end
    end

    def post_scriptum
      result = +""
      if @posts.any?
        result << "\n"

        @posts.each do |slug, post|
          result << "\n[#{slug}]#{default_public_post_path(post)}" if post
        end
      end

      result
    end

    def default_url_options
      { only_path: true }
    end

    def locale
      @metadata[:locale] || I18n.locale
    end

    def current_locale_prefix
      locale_prefix(locale)
    end
  end
end

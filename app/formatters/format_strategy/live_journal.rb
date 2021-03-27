# frozen_string_literal: true

module FormatStrategy
  class LiveJournal < Base
    include VideoEmbedderHelper

    include SpeciesHelper
    include ImagesHelper
    include ActionView::Helpers::TagHelper

    include FullPathMethods

  def initialize(text, metadata = {})
    super
  end

    def lj_user(user)
      %Q(<lj user="#{user}">)
    end

    def post_tag(word, term)
      post = @posts[term]
      post.nil? || post.lj_url.nil? ?
        word :
        %Q("#{word || post.decorated.title}":#{term})
    end

    def img_tag(term)
      if image = Image.find_by(slug: term)
        real_image_tag(image)
      end
    end

    def real_image_tag(image)
      %Q(<figure class="imageholder">
          !#{static_jpg_url(image)}([photo])!
          <figcaption class="imagetitle">
          #{image.decorated.title} __(#{image.species.map(&:name_sci).join(', ')})__
          </figcaption>
        </figure>
        )
    end

    def species_tag(word, term, en)
      sp = @species[term]
      if sp
        str = String.new %Q(<b title="#{sp.name_sci}">#{word or (en ? sp.name_en : sp.name_sci)}</b>)
        #%Q("(sp_link). #{word || sp.name_sci}":#{sp.code})
        if en && word.present?
          str << " (#{sp.name_en})"
        end
        str
      else
        term.size > 6 ? unknown_species(word, term) : (word || term)
      end
    end

    def post_scriptum
      result = String.new ""

      images = @metadata[:images]
      if images.any?
        result << "\n\n"
        images.each_with_index do |img, i|
          result << "<lj-cut text=\"#{images[1..-1].map(&:public_title).to_sentence.capitalize}\">\n\n" if i == 1
          result << "#{real_image_tag(img)}\n\n"
        end
        result << "</lj-cut>" if images.size > 1
      end

      if @posts.any? || @spcs.any?
        result << "\n"

        @posts.each do |slug, post|
          result << "\n[#{slug}]#{post.lj_url}" if post&.lj_url
        end
      end

      result
    end
  end
end

class LJFormatStrategy < FormattingStrategy

  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper

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
    if image = Image.find_by(slug: term)
      real_image_tag(image)
    end
  end

  def real_image_tag(image)
    %Q(<figure class="imageholder">
          !#{jpg_url(image)}([photo])!
          <figcaption class="imagetitle">
          #{image.formatted.title} __(#{image.species.map(&:name_sci).join(', ')})__
          </figcaption>
        </figure>
        )
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
        result << "<lj-cut>\n\n" if i == 1
        result << "#{real_image_tag(img)}\n\n"
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

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
    if image = Image.find_by_slug(term)
      %Q(!#{jpg_url(image)}([photo])!\n#{image.formatted.title} __(#{image.species.map(&:name_sci).join(', ')})__)
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
        result << "<lj-cut>\n\n" if i == 1
        title = img.formatted.title
        result << "<p>!#{jpg_url(img)}(#{title})!\n#{title} __(#{img.species.map(&:name_sci).join(', ')})__</p>\n\n"
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

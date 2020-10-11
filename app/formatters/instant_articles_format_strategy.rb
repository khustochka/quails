# frozen_string_literal: true

class InstantArticlesFormatStrategy < FeedFormatStrategy

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

  def post_scriptum
    result = String.new ""

    images = @metadata[:images]
    if images.any?
      result << "\n\n"
      images.each do |img|
        result << "#{real_image_tag(img)}\n\n"
      end
    end

    result + super
  end

  private

  def preprocess(text)
    new_text = super(text)
    # Replace h3 with h2, h4-6 with strong
    new_text.
        gsub(/^h3\./i, "h2.").
        gsub(/<(\/?)h3/i, '<\1h2').
        gsub(/^h[4-6]\.\s+(.*)$/i, '*\1*').
        gsub(/<(\/?)h[4-6]/i, '<\1strong').
        # Replace textile footnotes with small text in brackets.
        gsub(/(\[\d+\])/, ' <notextile><small>\1</small></notextile>').
        gsub(/fn(\d+)\. /, '<notextile><small>[\1]</small></notextile> ').
        # Standalone images should be wrapped in figure
        gsub(/^!(.*)!$/, '<figure><img src="\1" /></figure>').
        gsub(/^(<img .*>)$/, '<figure>\1</figure>')
  end

end

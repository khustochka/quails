module ImagesHelper

  FLICKR_SIZES = {
      "NO FLICKR" => '',
      "Square" => 's',
      "Thumbnail" => 't',
      "Small" => 'm',
      "Medium" => '-',
      "Medium 640" => 'z',
      "Large" => 'b',
      "Original" => 'o'
  }

  def jpg_url(img)
    (img.on_flickr? && img.flickr_data['Original']['source']) ||
        legacy_image_url("#{img.slug}.jpg")
  end

  def thumbnail_url(img)
    (img.on_flickr? && img.flickr_data['Thumbnail']['source']) ||
        legacy_image_url("tn_#{img.slug}.jpg")
  end

  def image_title(image)
    img_title = RedCloth.new(image.public_title, [:no_span_caps, :lite_mode]).to_html.html_safe
    if block_given?
      yield img_title
    else
      img_title
    end
  end

  # TODO: Use Addressable::URI to parse and generate urls (better than stdlib's URI)
  def self.image_host=(host)
    @image_host = host
  end

  private

  def self.image_host
    Configurator.configure(ImagesHelper) unless @image_host
    @image_host
  end

  def legacy_image_url(file_name)
    "#{ImagesHelper.image_host}/aves/photos/#{file_name}"
  end

end

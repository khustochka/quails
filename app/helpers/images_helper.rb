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
    (img.flickr_size.present? && img.flickr_data[img.flickr_size]) ||
        legacy_image_url("#{img.slug}.jpg")
  end

  def thumbnail_url(img)
    (img.flickr_size.present? && img.flickr_data['t']) ||
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

  private

  def legacy_image_url(file_name)
    "#{IMAGES_HOST}/aves/photos/#{file_name}"
  end

end

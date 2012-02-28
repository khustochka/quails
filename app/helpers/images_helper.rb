module ImagesHelper

  def jpg_url(img)
    "#{IMAGES_HOST}/aves/photos/#{img.code}.jpg"
  end

  def thumbnail_url(img)
    "#{IMAGES_HOST}/aves/photos/tn_#{img.code}.jpg"
  end

  def image_title(image)
    RedCloth.new(image.public_title, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

end

module ImagesHelper

  def jpg_url(img, thumbnail = false)
    "#{IMAGES_HOST}/aves/photos/#{'tn_' if thumbnail}#{img.code}.jpg"
  end

  def image_title(image)
    RedCloth.new(image.public_title, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

end

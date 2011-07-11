module ImagesHelper

  def jpg_url(img, thumbnail = false)
    "http://birdwatch.org.ua/photos/#{'tn_' if thumbnail}#{img.code}.jpg"
  end

  def image_thumbnail(img)
    link_to image_tag(jpg_url(img, true)), public_image_path(img)
  end

end

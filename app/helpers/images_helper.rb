module ImagesHelper

  def jpg_url(img, thumbnail = false)
    "#{IMAGES_HOST}/photos/#{'tn_' if thumbnail}#{img.code}.jpg"
  end

end

module ImagesHelper

  def jpg_url(img, thumbnail = false)
    "#{IMAGES_HOST}/aves/photos/#{'tn_' if thumbnail}#{img.code}.jpg"
  end

end

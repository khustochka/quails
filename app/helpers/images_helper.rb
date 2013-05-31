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

  SENTENCE_SEPARATOR_DEPENDING_ON_POST = {
      true => ';',
      false => '.'
  }

  def sentence_separator_depending_on_post(post)
    SENTENCE_SEPARATOR_DEPENDING_ON_POST[post.present?]
  end

  def jpg_url(img)
    if img.on_flickr?
      img.assets_cache.externals.main_image.full_url
    else
      img.assets_cache.locals.main_image.try(:full_url) || legacy_image_url("#{img.slug}.jpg")
    end
  end

  def thumbnail_url(img)
    if img.has_old_thumbnail? || !img.on_flickr?
      img.assets_cache.locals.thumbnails.first.try(:full_url) || legacy_image_url("tn_#{img.slug}.jpg")
    else
      img.assets_cache.externals.thumbnails.first.full_url
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
    "#{ImagesHelper.image_host}/#{file_name}"
  end

end

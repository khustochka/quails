module ImagesHelper

  ON_FLICKR_IMG = {
      true => ["https://s.yimg.com/pw/images/goodies/white-small-chiclet.png", "On flickr"],
      false => ["https://s.yimg.com/pw/images/goodies/black-small-chiclet.png", "Not on flickr"]
  }

  def jpg_url(img)
    if img.on_s3?
      rails_blob_url(img.source_image, only_path: helper_only_path?)
    elsif img.on_flickr?
      img.assets_cache.externals.main_image.full_url
    else
      img.assets_cache.locals.main_image.try(:full_url) || legacy_image_url("#{img.slug}.jpg")
    end
  end

  def helper_only_path?
    @only_path ||= true
  end

  THUMBNAIL_HEIGHT = 218

  def thumbnail_item(img)
    if img.on_flickr?
      img.assets_cache.externals.thumbnail
    else
      img.assets_cache.locals.thumbnail
    end
  end
  
  def self.image_host=(host)
    @image_host = host
  end

  def self.local_image_path=(dir)
    @local_image_path = dir
  end

  def self.temp_image_path=(dir)
    @temp_image_path = dir
  end

  private

  def self.image_host
    @image_host ||= ENV['quails_image_host']
  end

  def self.local_image_path
    return @local_image_path if @local_image_path
    @local_image_path = ENV['quails_local_image_path']
    FileUtils.mkdir_p(@local_image_path) if @local_image_path
    @local_image_path
  end

  def self.temp_image_path
    return @temp_image_path if @temp_image_path
    @temp_image_path = ENV['quails_temp_image_path']
    FileUtils.mkdir_p(@temp_image_path) if @temp_image_path
    @temp_image_path
  end

  def legacy_image_url(file_name)
    "#{ImagesHelper.image_host}/#{file_name}"
  end

  def flickr_img_format
    @flickr_img_format || :url_m
  end

  def flickr_img_url_function(flickr_image)
    if @flickr_img_url_lambda
      @flickr_img_url_lambda.call(flickr_image)
    else
      FlickRaw.url_photopage(flickr_image)
    end
  end

end

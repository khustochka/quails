# frozen_string_literal: true

module ImagesHelper
  ON_FLICKR_IMG = {
    true => ["https://s.yimg.com/pw/images/goodies/white-small-chiclet.png", "On flickr"],
    false => ["https://s.yimg.com/pw/images/goodies/black-small-chiclet.png", "Not on flickr"],
  }

  def jpg_url(img)
    if img.on_storage?
      img.stored_image.url
    elsif img.on_flickr?
      img.assets_cache.externals.main_image.full_url
    else
      img.assets_cache.locals.main_image.try(:full_url) || legacy_image_url("#{img.slug}.jpg")
    end
  end

  def static_jpg_url(img, options = {})
    image_url(img, options.merge({ format: :jpg }))
  end

  THUMBNAIL_HEIGHT = 280

  def thumbnail_item(img)
    if img.on_storage?
      img.stored_image_to_asset_item
    elsif img.on_flickr?
      img.assets_cache.externals.thumbnail
    else
      img.assets_cache.locals.thumbnail
    end
  end

  class << self
    attr_writer :image_host
    attr_writer :local_image_path
    attr_writer :temp_image_path

    def image_host
      @image_host ||= ENV["quails_image_host"]
    end

    private

    def local_image_path
      return @local_image_path if @local_image_path

      @local_image_path = ENV["quails_local_image_path"]
      FileUtils.mkdir_p(@local_image_path) if @local_image_path
      @local_image_path
    end

    def temp_image_path
      return @temp_image_path if @temp_image_path

      @temp_image_path = ENV["quails_temp_image_path"]
      FileUtils.mkdir_p(@temp_image_path) if @temp_image_path
      @temp_image_path
    end
  end

  private

  def legacy_image_url(file_name)
    "#{ImagesHelper.image_host}#{file_name}"
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

  def srcset_convert_urls(srcset)
    srcset.map do |url, size|
      [url_for(url), size]
    end
  end
end

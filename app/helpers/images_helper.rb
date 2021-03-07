# frozen_string_literal: true

module ImagesHelper

  ON_FLICKR_IMG = {
      true => ["https://s.yimg.com/pw/images/goodies/white-small-chiclet.png", "On flickr"],
      false => ["https://s.yimg.com/pw/images/goodies/black-small-chiclet.png", "Not on flickr"]
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
    opts = {only_path: helper_only_path?}.merge!(options).merge({format: :jpg})
    image_url(img, opts)
  end

  def helper_only_path?
    @only_path.nil? ?  @only_path = true : @only_path
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
    @image_host ||= ENV["quails_image_host"]
  end

  def self.local_image_path
    return @local_image_path if @local_image_path
    @local_image_path = ENV["quails_local_image_path"]
    FileUtils.mkdir_p(@local_image_path) if @local_image_path
    @local_image_path
  end

  def self.temp_image_path
    return @temp_image_path if @temp_image_path
    @temp_image_path = ENV["quails_temp_image_path"]
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

  def srcset(image)
    representer = image.representer
    if image.on_storage?
      max_width = image.stored_image.metadata[:width]
      # We need larger sizes because Retina displays will require 2x size images.
      # E.g. for 1200px (default) it will try to find at least 2400px wide image
      # Similarly, for a thumbnail taking 1/3 column (appr. 380px) it will ask for 760px (thus I prepare 900px)
      new_sizes = [640, 900, 1200, 2400].select { |size| size < max_width }
      srcset = new_sizes.map { |size| [url_for(representer.variant(size)), "#{size}w"] }
      srcset << [url_for(image.stored_image), "#{max_width}w"]
      srcset
    elsif image.on_flickr?
      representer.flickr_srcset
    end
  end
end

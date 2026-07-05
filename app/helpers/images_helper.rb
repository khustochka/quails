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

  # Dimensions of the asset that jpg_url points to (nil if unknown),
  # for width/height img attributes reserving layout space before load.
  def jpg_dimensions(img)
    if img.on_storage?
      width, height = img.stored_image.metadata.values_at(:width, :height)
      { width: width, height: height } if width && height
    else
      asset = img.assets_cache.public_send(img.on_flickr? ? :externals : :locals).main_image
      { width: asset.width, height: asset.height } if asset && !asset.dummy_dimensions?
    end
  end

  # Fit the viewport height, but don't shrink in short-wide windows
  POST_IMG_HEIGHT_CAP = "max(97vh, 700px)"
  CANVAS_IMG_HEIGHT_CAP = "max(95vh, 700px)"

  # width/height attributes reserving layout space before load, plus the
  # viewport-height cap expressed as a width cap: the width attribute pins the
  # layout width, so a CSS max-height would squish the image instead of
  # scaling it down.
  def dimension_attrs(dims, cap: POST_IMG_HEIGHT_CAP)
    return {} unless dims

    {
      width: dims[:width], height: dims[:height],
      style: "max-width: min(100%, calc(#{cap} * #{dims[:width]} / #{dims[:height]}))",
    }
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

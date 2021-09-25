# frozen_string_literal: true

class Thumbnail
  class Title < Struct.new(:object, :to_partial_path)
  end

  include ImagesHelper

  attr_reader :url, :data, :image

  def initialize(url_or_object, title_or_partial, image, data = nil)
    @url = url_or_object
    @title_or_partial = title_or_partial
    @image = image
    @data = data
  end

  def title
    case @title_or_partial
    when String
        @title_or_partial
    when Hash
        @cached_title = Title.new(@url, @title_or_partial[:partial])
    end
  end

  def asset_url
    image_asset.full_url
  end

  def height
    @height ||= if @width
                  (image_asset.height * (@width.to_f / image_asset.width)).to_i
                else
                  THUMBNAIL_HEIGHT
                end
  end

  def width
    @width ||= (image_asset.width * (height.to_f / image_asset.height)).to_i
  end

  def dummy_dimensions?
    image_asset.dummy_dimensions?
  end

  def force_width(value)
    @width = value
    @height = nil
  end

  def force_dimensions(value)
    value.each do |key, val|
      self.instance_variable_set("@#{key}".to_sym, val)
    end
  end

  def to_partial_path
    "images/thumbnail"
  end

  def video?
    @image.video?
  end

  private
  def image_asset
    if @image.on_storage?
      @image.stored_image_to_asset_item
    elsif @image.external_id
      @image.assets_cache.externals.find_max_size(height: [@height || THUMBNAIL_HEIGHT, 436].max)
    else
      @image.assets_cache.locals.find_max_size(height: [@height || THUMBNAIL_HEIGHT, 436].max)
    end
  end

  def dimensions_set?
    @width || @height
  end
end

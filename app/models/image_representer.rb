# frozen_string_literal: true

class ImageRepresenter
  include Rails.application.routes.url_helpers

  attr_reader :image

  def initialize(image)
    @image = image
  end

  # TODO: make adjustments for height

  # Large is an image representation with maximum width 1200px
  def large
    if image.on_storage?
      variant(1200)
    else
      relevant_assets_cache.select { |item| item.width <= 1200 }.max_by(&:width).url
    end
  end

  # For large images they usually take whole almost viewport
  def fullscreen_sizes
    "(min-width: #{fullscreen_max_width}px) #{fullscreen_max_width}px, 100vw"
  end

  def fullscreen_max_width
    # If we always set "(min-width: 1200px) 1200px" it will stretch smaller images.
    [1200, max_width].compact.min
  end

  def max_width
    if image.on_storage?
      image.stored_image.metadata[:width]
    else
      relevant_assets_cache.map(&:width).max
    end
  end

  def srcset
    if image.on_storage?
      storage_srcset
    else
      static_srcset
    end
  end

  def static_srcset
    # Remove smallest thumbnails, some of which are cropped
    items = relevant_assets_cache.delete_if { |item| item.width <= 150 }
    items.map { |item| [item.url, "#{item.width}w"] }
  end

  def storage_srcset
    # We need larger sizes because Retina displays will require 2x size images.
    # E.g. for 1200px (default) it will try to find at least 2400px wide image
    # Similarly, for a thumbnail taking 1/3 column (appr. 380px) it will ask for 760px (thus I prepare 900px)
    # P.S. If width is unknown (test or identification failure) - we just request variants
    new_sizes = [640, 900, 1200, 2400]
    new_sizes = new_sizes.select { |size| size < max_width } if max_width
    srcset = new_sizes.map { |size| [variant(size), "#{size}w"] }
    srcset << [image.stored_image, "#{max_width}w"] if max_width
    srcset
  end

  def variant(width)
    image.stored_image.variant(ImageRepresenter.resize_and_save_space([width, nil]))
  end

  # TODO: Make adjustments for images already saved with worse quality?
  def self.resize_and_save_space(dimensions)
    {
      resize_to_limit: dimensions,
      saver: {
        quality: 85, strip: true, optimize_coding: true,
        trellis_quant: true, quant_table: 3, keep: nil,
      },
    }
  end

  private

  def relevant_assets_cache
    key = image.on_flickr? ? :externals : :locals
    image.assets_cache.public_send(key)
  end
end

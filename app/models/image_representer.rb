# frozen_string_literal: true

class ImageRepresenter
  include Rails.application.routes.url_helpers

  attr_reader :image

  NAME_TO_WIDTH = {
    small: 640,
    thumbnail: 900,
    medium: 1200,
    large: 2400,
  }

  WIDTH_TO_NAME = NAME_TO_WIDTH.invert

  def initialize(image)
    @image = image
  end

  # TODO: make adjustments for height

  # Large is an image representation with maximum width 1200px
  def large
    if image.on_storage?
      variant_source(:medium)
    else
      large_asset.url
    end
  end

  # Natural dimensions of the large representation (nil if unknown), for
  # width/height img attributes reserving layout space before load.
  def dimensions
    if image.on_storage?
      width, height = image.stored_image.metadata.values_at(:width, :height)
      return unless width && height

      limit = NAME_TO_WIDTH[:medium]
      if width > limit
        height = (height * limit / width.to_f).round
        width = limit
      end
      { width: width, height: height }
    elsif (asset = large_asset) && !asset.dummy_dimensions?
      { width: asset.width, height: asset.height }
    end
  end

  # For large images they usually take almost entire viewport
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
    new_sizes = WIDTH_TO_NAME.keys
    new_sizes = new_sizes.select { |size| size < max_width } if max_width
    srcset = new_sizes.map { |size| [variant_source(WIDTH_TO_NAME[size]), "#{size}w"] }
    srcset << [blob_source, "#{max_width}w"] if max_width
    srcset
  end

  def variant(name)
    image.stored_image.variant(name)
  end

  # Direct storage URL when the variant is already processed (nil otherwise),
  # or the variant itself, which renders as the lazily-generating redirect route.
  def variant_source(name)
    source = variant(name)
    (source.url if Quails.direct_variant_urls?) || source
  end

  def self.variant_format(name)
    # This is the order in which "transformations" end up in the job. To avoid
    # duplicating the variant the ordre should be followed. If any options need to be
    # changed, one needs to check the resulting order in development.
    {
      saver: {
        keep: nil, strip: true, quality: 85, optimize_coding: true,
      },
      resize_to_limit: [NAME_TO_WIDTH[name.to_sym], nil],
    }
  end

  private

  def blob_source
    (image.stored_image.url if Quails.direct_variant_urls?) || image.stored_image
  end

  def large_asset
    relevant_assets_cache.select { |item| item.width <= 1200 }.max_by(&:width)
  end

  def relevant_assets_cache
    key = image.on_flickr? ? :externals : :locals
    image.assets_cache.public_send(key)
  end
end

# frozen_string_literal: true

class ImageRepresenter
  include Rails.application.routes.url_helpers

  def initialize(image)
    @image = image
  end

  # TODO: make adjustments for height

  # Large is an image representation with maximum width 1200px
  def large
    if @image.on_storage?
      variant(1200)
    elsif @image.on_flickr?
      @image.assets_cache.externals.select {|item| item.width <= 1200}.sort_by(&:width).last.url
    end
  end

  # For large images they usually take whole almost viewport
  def fullscreen_sizes
    "(min-width:1200px) 1200px, 100vw"
  end

  def flickr_srcset
    # Remove smallest thumbnails, some of which are cropped
    items = @image.assets_cache.externals.delete_if {|item| item.width <= 150}
    items.map {|item| [item.url, "#{item.width}w"]}
  end

  def variant(width)
    @image.stored_image.variant(resize_and_save_space("#{width}x>"))
  end

  private

  # TODO: Make adjustments for images already saved with worse quality?
  def resize_and_save_space(resizing)
    {resize: resizing, quality: "85%", strip: true, interlace: "Plane"}
  end


end
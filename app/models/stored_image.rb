# frozen_string_literal: true

module StoredImage
  SIZE_VARIANTS = [640, 900, 1200, 2400]

  def variant_of_width(desired_width)
    variant(resize_and_save_space("#{desired_width.round}x>")).extend(StoredVariant)
  end

  def width
    metadata.fetch(:width, nil)
  end

  def height
    metadata.fetch(:height, nil)
  end

  def srcset
    # We need larger sizes because Retina displays will require 2x size images.
    # E.g. for 1200px (default) it will try to find at least 2400px wide image
    # Similarly, for a thumbnail taking 1/3 column (appr. 380px) it will ask for 760px (thus I prepare 900px)
    # P.S. If width is unknown (test or identification failure) - we just request variants
    size_variants.map { |size| [variant_of_width(size), "#{size}w"] }
  end

  def portrait?
    width && height && height >= width
  end

  private
  # TODO: Make adjustments for images already saved with worse quality?
  def resize_and_save_space(resizing)
    {resize: resizing, quality: "85%", strip: true, interlace: "Plane"}
  end

  def size_variants
    portrait? ? SIZE_VARIANTS.map {|w| (w * 0.66).round} : SIZE_VARIANTS
  end
end

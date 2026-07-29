# frozen_string_literal: true

require "test_helper"

class ImagesHelperTest < ActionView::TestCase
  test "jpg_dimensions returns the main asset dimensions for a local image" do
    image = create(:image)
    assert_equal({ width: 800, height: 600 }, jpg_dimensions(image))
  end

  test "jpg_dimensions returns the main asset dimensions for a flickr image" do
    image = create(:image_on_flickr)
    assert_equal({ width: 800, height: 600 }, jpg_dimensions(image))
  end

  test "jpg_dimensions is nil when asset dimensions are unknown" do
    image = create(:image, assets_cache: ImageAssetsArray.new([ImageAssetItem.new(:local, 0, 0, "/photos/x.jpg")]))
    assert_nil jpg_dimensions(image)
  end

  test "dimension_attrs builds width, height and an aspect ratio" do
    attrs = dimension_attrs({ width: 800, height: 1200 })
    assert_equal 800, attrs[:width]
    assert_equal 1200, attrs[:height]
    assert_equal "aspect-ratio: 800 / 1200", attrs[:style]
  end

  test "dimension_attrs is empty without dimensions" do
    assert_equal({}, dimension_attrs(nil))
  end

  # The cap sizes the wrapper, not the image: a percentage width on the image
  # would make the shrink-to-fit wrapper measure it at its full width attribute.
  test "image_frame_attrs caps the wrapper by container, natural width and height" do
    attrs = image_frame_attrs({ width: 800, height: 1200 })
    assert_equal "width: min(100%, 800px, calc(max(97vh, 700px) * 800 / 1200))", attrs[:style]
  end

  test "image_frame_attrs accepts a custom cap" do
    attrs = image_frame_attrs({ width: 800, height: 600 }, cap: ImagesHelper::CANVAS_IMG_HEIGHT_CAP)
    assert_equal "width: min(100%, 800px, calc(max(95vh, 700px) * 800 / 600))", attrs[:style]
  end

  test "image_frame_attrs is empty without dimensions" do
    assert_equal({}, image_frame_attrs(nil))
  end

  test "variant_src_with_fallback returns the variant when the flag is off" do
    variant = create(:image_on_storage).thumbnail_variant
    assert_equal [variant, {}], variant_src_with_fallback(variant)
  end

  test "variant_src_with_fallback returns a direct url with a redirect fallback for a processed variant" do
    with_direct_variant_urls do
      variant = create(:image_on_storage).thumbnail_variant
      src, attrs = variant_src_with_fallback(variant)
      assert_match %r{/rails/active_storage/disk/}, src
      assert_match %r{/rails/active_storage/representations/redirect/}, attrs[:data][:fallback_src]
    end
  end

  test "variant_src_with_fallback returns an unprocessed variant unchanged" do
    with_direct_variant_urls do
      variant = create(:image_on_storage).stored_image.variant(:medium)
      assert_equal [variant, {}], variant_src_with_fallback(variant)
    end
  end

  test "variant_src_with_fallback passes through plain urls" do
    with_direct_variant_urls do
      assert_equal ["/photos/x.jpg", {}], variant_src_with_fallback("/photos/x.jpg")
    end
  end
end

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

  test "dimension_attrs builds width, height and a width-expressed height cap" do
    attrs = dimension_attrs({ width: 800, height: 1200 })
    assert_equal 800, attrs[:width]
    assert_equal 1200, attrs[:height]
    assert_equal "max-width: min(100%, calc(max(97vh, 700px) * 800 / 1200))", attrs[:style]
  end

  test "dimension_attrs accepts a custom cap" do
    attrs = dimension_attrs({ width: 800, height: 600 }, cap: ImagesHelper::CANVAS_IMG_HEIGHT_CAP)
    assert_equal "max-width: min(100%, calc(max(95vh, 700px) * 800 / 600))", attrs[:style]
  end

  test "dimension_attrs is empty without dimensions" do
    assert_equal({}, dimension_attrs(nil))
  end
end

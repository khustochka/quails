# frozen_string_literal: true

require "test_helper"

class ImageRepresenterTest < ActiveSupport::TestCase
  test "dimensions returns the large asset dimensions" do
    image = create(:image)
    assert_equal({ width: 800, height: 600 }, image.representer.dimensions)
  end

  test "dimensions is nil when asset dimensions are unknown" do
    image = create(:image, assets_cache: ImageAssetsArray.new([ImageAssetItem.new(:local, 0, 0, "/photos/x.jpg")]))
    assert_nil image.representer.dimensions
  end

  test "dimensions scales stored image metadata down to the medium variant limit" do
    image = create(:image_on_storage)
    image.stored_image.blob.update!(metadata: { width: 4000, height: 3000 })
    assert_equal({ width: 1200, height: 900 }, image.representer.dimensions)
  end

  test "dimensions keeps stored image metadata below the medium variant limit" do
    image = create(:image_on_storage)
    image.stored_image.blob.update!(metadata: { width: 350, height: 248 })
    assert_equal({ width: 350, height: 248 }, image.representer.dimensions)
  end

  test "dimensions is nil for stored image without analyzed metadata" do
    image = create(:image_on_storage)
    image.stored_image.blob.update!(metadata: {})
    assert_nil image.representer.dimensions
  end
end

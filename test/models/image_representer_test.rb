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

  test "srcset returns variants when the flag is off" do
    image = create(:image_on_storage)
    image.representer.srcset.each do |source, _width|
      assert_kind_of ActiveStorage::VariantWithRecord, source
    end
  end

  test "srcset returns direct urls for processed variants and keeps redirect for the rest" do
    with_direct_variant_urls do
      image = create(:image_on_storage)
      srcset = image.representer.srcset.to_h { |source, width| [width, source] }
      # :small is preprocessed on attach, :medium is not
      assert_match %r{/rails/active_storage/disk/}, srcset["640w"]
      assert_kind_of ActiveStorage::VariantWithRecord, srcset["1200w"]
    end
  end

  test "large returns a direct url for a processed medium variant" do
    with_direct_variant_urls do
      image = create(:image_on_storage)
      image.stored_image.variant(:medium).processed
      assert_match %r{/rails/active_storage/disk/}, image.representer.large
    end
  end

  test "large returns the variant when the medium variant is not processed" do
    with_direct_variant_urls do
      image = create(:image_on_storage)
      assert_kind_of ActiveStorage::VariantWithRecord, image.representer.large
    end
  end
end

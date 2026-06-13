# frozen_string_literal: true

require "test_helper"

module API
  class ImagesControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      create(:image)
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_not_empty response.parsed_body[:rows]
    end

    test "pagination" do
      images = create_list(:image, 5)
      get api_images_url, params: { format: :json, page: 2, per_page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_equal images[2..3].map(&:id), response.parsed_body[:rows].map(&:first)
    end

    test "it includes observation_ids" do
      card = create(:card)
      observations = create_list(:observation, 2, card: card)
      image = create(:image, observations: observations)
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      idx = response.parsed_body[:columns].index("observation_ids")

      assert_not_nil idx
      row = response.parsed_body[:rows].find { |r| r.first == image.id }
      assert_equal observations.map(&:id).sort, row[idx]
    end

    test "original_url for a storage-hosted image is the stored_image blob url" do
      image = create(:image_on_storage)
      # The Disk service signs URLs with an expiry, so freeze time to keep the
      # request and the expected URL identical. Public S3 URLs are stable.
      freeze_time do
        get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

        assert_response :success
        idx = response.parsed_body[:columns].index("original_url")
        row = response.parsed_body[:rows].find { |r| r.first == image.id }

        assert_not_nil idx
        expected = ActiveStorage::Current.set(url_options: { host: "http://www.example.com" }) do
          image.stored_image.url
        end
        assert_equal expected, row[idx]
      end
    end

    test "original_url for a flickr-hosted image is the largest cached asset" do
      image = create(:image_on_flickr)
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      idx = response.parsed_body[:columns].index("original_url")
      row = response.parsed_body[:rows].find { |r| r.first == image.id }

      assert_equal image.assets_cache.externals.original.full_url, row[idx]
    end

    test "meta for a storage-hosted image carries blob dimensions and content type" do
      image = create(:image_on_storage)
      blob = image.stored_image.blob
      blob.update!(metadata: blob.metadata.merge(width: 1200, height: 800))
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      idx = response.parsed_body[:columns].index("meta")
      row = response.parsed_body[:rows].find { |r| r.first == image.id }
      meta = row[idx]

      assert_not_nil idx
      assert_equal 1200, meta["width"]
      assert_equal 800, meta["height"]
      assert_equal blob.content_type, meta["content_type"]
    end

    test "meta includes exif_date when present in blob metadata" do
      image = create(:image_on_storage)
      blob = image.stored_image.blob
      blob.update!(metadata: blob.metadata.merge(exif_date: "2024-05-01 10:20:30"))
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      idx = response.parsed_body[:columns].index("meta")
      row = response.parsed_body[:rows].find { |r| r.first == image.id }

      assert_equal "2024-05-01 10:20:30", row[idx]["exif_date"]
    end

    test "meta for a flickr-hosted image carries the largest asset dimensions" do
      image = create(:image_on_flickr)
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      idx = response.parsed_body[:columns].index("meta")
      row = response.parsed_body[:rows].find { |r| r.first == image.id }
      original = image.assets_cache.externals.original

      assert_equal original.width, row[idx]["width"]
      assert_equal original.height, row[idx]["height"]
      assert_nil row[idx]["content_type"]
    end

    test "observation_ids is an empty array when image has no observations" do
      image = create(:image)
      image.observations.destroy_all
      get api_images_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      idx = response.parsed_body[:columns].index("observation_ids")
      row = response.parsed_body[:rows].find { |r| r.first == image.id }

      assert_equal [], row[idx]
    end
  end
end

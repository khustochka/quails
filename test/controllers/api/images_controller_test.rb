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

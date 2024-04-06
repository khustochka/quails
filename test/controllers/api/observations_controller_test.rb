# frozen_string_literal: true

require "test_helper"

module API
  class ObservationsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      create(:observation)
      get api_observations_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_not_empty response.parsed_body[:rows]
    end

    test "pagination" do
      observations = create_list(:observation, 5)
      get api_observations_url, params: { format: :json, page: 2, per_page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_equal observations[2..3].map(&:id), response.parsed_body[:rows].map(&:first)
    end

    test "it includes taxon ebird code" do
      observation = create(:observation)
      get api_observations_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      idx = response.parsed_body[:columns].index("ebird_code")

      assert_not_nil idx
      assert_equal [observation.taxon.ebird_code], response.parsed_body[:rows].pluck(idx)
    end
  end
end

# frozen_string_literal: true

require "test_helper"

module API
  class ObservationsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      create(:observation)
      get api_observations_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_not response.parsed_body.empty?
    end

    test "pagination" do
      observations = create_list(:observation, 5)
      get api_observations_url, params: { format: :json, page: 2, per_page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_equal observations[2..3].map(&:id), response.parsed_body.pluck(:id)
    end

    test "it includes taxon ebird code" do
      observation = create(:observation)
      get api_observations_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_equal observation.taxon.ebird_code, response.parsed_body.pick(:ebird_code)
    end
  end
end

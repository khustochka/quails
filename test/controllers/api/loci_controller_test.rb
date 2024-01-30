# frozen_string_literal: true

require "test_helper"

module API
  class LociControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get api_loci_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_not response.parsed_body.empty?
    end

    test "pagination" do
      get api_loci_url, params: { format: :json, page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_empty response.parsed_body
    end
  end
end

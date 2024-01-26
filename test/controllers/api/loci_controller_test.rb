# frozen_string_literal: true

require "test_helper"

module API
  class LociControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get api_loci_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Token test1234" }

      assert_response :success
      assert_not response.parsed_body.empty?
    end
  end
end

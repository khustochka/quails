# frozen_string_literal: true

require "test_helper"

module API
  class CardsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      create(:card)
      get api_cards_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Token test1234" }

      assert_response :success
      assert_not response.parsed_body.empty?
    end

    test "pagination" do
      cards = create_list(:card, 5)
      get api_cards_url, params: { format: :json, page: 2, per_page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Token test1234" }

      assert_equal cards[2..3].map(&:id), response.parsed_body.pluck("id")
    end
  end
end

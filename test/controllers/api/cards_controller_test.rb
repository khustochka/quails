# frozen_string_literal: true

require "test_helper"

module API
  class CardsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      create(:card)
      get api_cards_url, params: { format: :json }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_response :success
      assert_not_empty response.parsed_body[:rows]
    end

    test "pagination" do
      cards = create_list(:card, 5)
      get api_cards_url, params: { format: :json, page: 2, per_page: 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer test1234" }

      assert_equal cards[2..3].map(&:id), response.parsed_body[:rows].map(&:first)
    end
  end
end

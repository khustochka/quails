# frozen_string_literal: true

require "test_helper"

module API
  class ExternalChecklistsControllerTest < ActionDispatch::IntegrationTest
    AUTH = { "HTTP_AUTHORIZATION" => "Bearer test1234" }.freeze

    test "upserts pushed checklists" do
      create(:card, ebird_id: "S1")
      checklists = [
        { external_id: "S1", location: "Brovary" },
        { external_id: "S2", time: "23 Sep 2026 7:15 AM", location: "Brovary", county: "Brovarskyi", state_prov: "Kyiv, Ukraine" },
      ]
      post api_external_checklists_url, params: { checklists: checklists }, as: :json, headers: AUTH

      assert_response :success
      assert_equal 1, response.parsed_body[:upserted]
      checklist = ExternalChecklist.sole
      assert_equal "S2", checklist.external_id
      assert_equal "Kyiv, Ukraine", checklist.state_prov
    end

    test "accepts token-authenticated request with forgery protection enabled" do
      ActionController::Base.allow_forgery_protection = true
      post api_external_checklists_url, params: { checklists: [{ external_id: "S2" }] }, as: :json, headers: AUTH

      assert_response :success
    ensure
      ActionController::Base.allow_forgery_protection = false
    end

    test "rejects request without valid token" do
      post api_external_checklists_url, params: { checklists: [{ external_id: "S2" }] }, as: :json,
        headers: { "HTTP_AUTHORIZATION" => "Bearer wrong" }

      assert_response :unauthorized
      assert_empty ExternalChecklist.all
    end

    test "requires checklists param" do
      post api_external_checklists_url, params: {}, as: :json, headers: AUTH

      assert_response :bad_request
    end
  end
end

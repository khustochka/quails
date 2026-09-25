# frozen_string_literal: true

require "test_helper"

module API
  class ExternalChecklistsControllerTest < ActionDispatch::IntegrationTest
    include ActionCable::TestHelper

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

    test "broadcasts the updated list" do
      assert_broadcasts(ExternalChecklistsChannel.broadcasting_for(:external_checklists), 1) do
        post api_external_checklists_url, params: { checklists: [{ external_id: "S2" }] }, as: :json, headers: AUTH
      end
    end

    test "records preload time" do
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new

      freeze_time do
        post api_external_checklists_url, params: { checklists: [] }, as: :json, headers: AUTH

        assert_equal Time.current, ExternalChecklist.last_preload_at
      end
    ensure
      Rails.cache = original
    end

    test "accepts empty checklists" do
      post api_external_checklists_url, params: { checklists: [] }, as: :json, headers: AUTH

      assert_response :success
      assert_equal 0, response.parsed_body[:upserted]
    end

    test "broadcasts pushed error" do
      assert_broadcast_on(ExternalChecklistsChannel.broadcasting_for(:external_checklists), { error: "eBird login failed" }) do
        post api_external_checklists_url, params: { error: "eBird login failed" }, as: :json, headers: AUTH
      end

      assert_response :success
      assert_empty ExternalChecklist.all
    end

    test "requires checklists param" do
      post api_external_checklists_url, params: {}, as: :json, headers: AUTH

      assert_response :bad_request
    end

    test "imports pushed checklist" do
      create(:external_checklist, external_id: "S5", locus: Locus.find_by!(slug: "brovary"), status: "requested")
      checklist = { observ_date: "2026-09-19", start_time: "07:05", protocol: "Stationary", duration_minutes: 30,
                    observations: [{ name: "House Sparrow", species_code: "houspa", count: "5", comments: "V", obs_id: "OBS1" }], }

      assert_difference "Card.count" do
        post import_api_external_checklists_url, params: { external_id: "S5", checklist: checklist }, as: :json, headers: AUTH
      end

      assert_response :success
      assert_equal "imported", response.parsed_body[:status]
      obs = Card.find_by!(ebird_id: "S5").observations.sole
      assert obs.voice
      assert_equal "OBS1", obs.ebird_obs_id
    end

    test "reports failed import" do
      create(:external_checklist, external_id: "S5")

      post import_api_external_checklists_url, params: { external_id: "S5", checklist: { observ_date: "2026-09-19" } },
        as: :json, headers: AUTH

      assert_response :unprocessable_content
      assert_equal "No locus selected.", response.parsed_body[:error]
    end

    test "records error pushed for checklist" do
      checklist = create(:external_checklist, external_id: "S5", status: "requested")

      post import_api_external_checklists_url, params: { external_id: "S5", error: "Checklist not found on eBird" },
        as: :json, headers: AUTH

      assert_response :unprocessable_content
      assert_predicate checklist.reload, :failed?
      assert_equal "Checklist not found on eBird", checklist.error
    end

    test "rejects unknown checklist" do
      post import_api_external_checklists_url, params: { external_id: "S404", checklist: {} }, as: :json, headers: AUTH

      assert_response :not_found
    end

    test "rejects already imported checklist" do
      create(:external_checklist, external_id: "S5", status: "imported")

      assert_no_difference "Card.count" do
        post import_api_external_checklists_url, params: { external_id: "S5", checklist: { observ_date: "2026-09-19" } },
          as: :json, headers: AUTH
      end

      assert_response :conflict
    end
  end
end

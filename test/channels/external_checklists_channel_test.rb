# frozen_string_literal: true

require "test_helper"

class ExternalChecklistsChannelTest < ActionCable::Channel::TestCase
  test "admin subscribes" do
    stub_connection current_user: "admin"
    subscribe

    assert_predicate subscription, :confirmed?
    assert_has_stream_for :external_checklists
  end

  test "non-admin is rejected" do
    stub_connection current_user: nil
    subscribe

    assert_predicate subscription, :rejected?
  end

  test "broadcasts rendered list" do
    create(:external_checklist, external_id: "S777")

    ExternalChecklistsChannel.broadcast_list(upserted: 1)

    data = JSON.parse(broadcasts(ExternalChecklistsChannel.broadcasting_for(:external_checklists)).sole)
    assert_equal 1, data["upserted"]
    assert_includes data["html"], "S777"
    assert_includes data["html"], "locus_select"
  end

  def broadcast_data
    broadcasts(ExternalChecklistsChannel.broadcasting_for(:external_checklists)).map { |msg| JSON.parse(msg) }
  end

  test "broadcasts imported checklist status with card url" do
    card = create(:card, ebird_id: "S777")
    checklist = create(:external_checklist, external_id: "S777", status: "imported")

    ExternalChecklistsChannel.broadcast_status(checklist)

    data = broadcast_data.sole["checklist"]
    assert_equal checklist.id, data["id"]
    assert_equal "imported", data["status"]
    assert_equal "/cards/#{card.id}", data["card_url"]
    assert_includes data["status_html"], "fa-circle-check"
  end

  test "broadcasts failed checklist status with error" do
    checklist = create(:external_checklist, status: "failed", error: "Boom")

    ExternalChecklistsChannel.broadcast_status(checklist)

    data = broadcast_data.sole["checklist"]
    assert_equal "failed", data["status"]
    assert_nil data["card_url"]
    assert_includes data["status_html"], "fa-circle-exclamation"
    assert_includes data["status_html"], "Boom"
  end
end

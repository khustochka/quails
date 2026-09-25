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
end

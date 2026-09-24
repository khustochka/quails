# frozen_string_literal: true

require "test_helper"

class ExternalChecklistTest < ActiveSupport::TestCase
  test "defaults to pending status" do
    assert_predicate create(:external_checklist), :pending?
  end

  test "external_id is required" do
    assert_not_predicate build(:external_checklist, external_id: ""), :valid?
  end

  test "external_id is unique" do
    create(:external_checklist, external_id: "S123")
    assert_not_predicate build(:external_checklist, external_id: "S123"), :valid?
  end

  test "unknown status is invalid" do
    assert_not_predicate build(:external_checklist, status: "bogus"), :valid?
  end
end

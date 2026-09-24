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

  test "upsert_preloads creates new pending checklists" do
    count = ExternalChecklist.upsert_preloads([{ external_id: "S1", location: "Brovary" }, { "external_id" => "S2" }])

    assert_equal 2, count
    assert_equal %w(S1 S2), ExternalChecklist.order(:external_id).pluck(:external_id)
    assert ExternalChecklist.all.all?(&:pending?)
  end

  test "upsert_preloads skips checklists already imported as cards" do
    create(:card, ebird_id: "S1")

    assert_equal 1, ExternalChecklist.upsert_preloads([{ external_id: "S1" }, { external_id: "S2" }])
    assert_equal ["S2"], ExternalChecklist.pluck(:external_id)
  end

  test "upsert_preloads updates metadata but keeps review state" do
    locus = Locus.find_by!(slug: "brovary")
    checklist = create(:external_checklist, external_id: "S1", location: "Old", locus: locus, status: "failed")

    ExternalChecklist.upsert_preloads([{ external_id: "S1", location: "New" }])

    checklist.reload
    assert_equal "New", checklist.location
    assert_equal locus, checklist.locus
    assert_predicate checklist, :failed?
  end

  test "upsert_preloads ignores rows without id and unknown attributes" do
    assert_equal 1, ExternalChecklist.upsert_preloads([{ external_id: "" }, { external_id: "S1", status: "imported" }])
    assert_predicate ExternalChecklist.find_by(external_id: "S1"), :pending?
  end
end

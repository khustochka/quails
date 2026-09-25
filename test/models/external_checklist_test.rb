# frozen_string_literal: true

require "test_helper"

class ExternalChecklistTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  def status_broadcasts
    broadcasts(ExternalChecklistsChannel.broadcasting_for(:external_checklists)).map { |msg| JSON.parse(msg)["checklist"] }
  end
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

  test "suggests locus by location name and parent by county or state" do
    locus = create(:locus, name_en: "Cordite Trail")
    county = create(:locus, name_en: "Winnipeg")
    checklist = build(:external_checklist, location: "Cordite Trail", county: "Winnipeg")

    assert_equal locus.id, checklist.suggested_locus_id
    assert_equal county.id, checklist.suggested_parent_id
  end

  test "suggests parent by state when county is missing" do
    state = create(:locus, name_en: "Manitoba")
    checklist = build(:external_checklist, county: nil, state_prov: "Manitoba")

    assert_equal state.id, checklist.suggested_parent_id
  end

  def checklist_data(**overrides)
    { observ_date: "2026-09-19", protocol: "Incidental",
      observations: [{ name: "House Sparrow", species_code: "houspa", count: "5" }], }.merge(overrides)
  end

  test "import creates card at selected locus" do
    locus = Locus.find_by!(slug: "brovary")
    checklist = create(:external_checklist, external_id: "S123", locus: locus, status: "requested")

    card = checklist.import(checklist_data)

    assert_predicate card, :persisted?
    assert_equal locus, card.locus
    assert_equal "S123", card.ebird_id
    assert_predicate card, :resolved?
    assert_equal 1, card.observations.count
    assert_predicate checklist.reload, :imported?
  end

  test "import fails without locus" do
    checklist = create(:external_checklist)

    assert_nil checklist.import(checklist_data)
    assert_predicate checklist.reload, :failed?
    assert_equal "No locus selected.", checklist.error
  end

  test "import fails on unknown taxon without creating card" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))

    assert_no_difference "Card.count" do
      assert_nil checklist.import(checklist_data(observations: [{ name: "Dodo", count: "1" }]))
    end
    assert_predicate checklist.reload, :failed?
    assert_match(/Unknown taxon/, checklist.error)
  end

  test "import fails on invalid card" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))

    assert_nil checklist.import(checklist_data(protocol: "Nocturnal Flight Call Count"))
    assert_predicate checklist.reload, :failed?
    assert_match(/Effort type/, checklist.error)
  end

  test "import fails when card with the same ID exists" do
    create(:card, ebird_id: "S123")
    checklist = create(:external_checklist, external_id: "S123", locus: Locus.find_by!(slug: "brovary"))

    assert_nil checklist.import(checklist_data)
    assert_predicate checklist.reload, :failed?
  end

  test "successful import clears previous error" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"), status: "failed", error: "Boom")

    checklist.import(checklist_data)

    assert_predicate checklist.reload, :imported?
    assert_nil checklist.error
  end

  def with_birdnik_url(url = "http://birdnik.test")
    original = ENV["BIRDNIK_API_URL"]
    ENV["BIRDNIK_API_URL"] = url
    yield
  ensure
    ENV["BIRDNIK_API_URL"] = original
  end

  test "request_import requests reviewable checklists with locus" do
    locus = Locus.find_by!(slug: "brovary")
    pending = create(:external_checklist, locus: locus)
    failed = create(:external_checklist, locus: locus, status: "failed", error: "Boom")
    no_locus = create(:external_checklist)
    create(:external_checklist, locus: locus, status: "imported")
    stub = stub_request(:post, "http://birdnik.test/fetches")
      .with { |req| JSON.parse(req.body)["external_ids"].sort == [pending, failed].map(&:external_id).sort }
      .to_return(status: 202)

    requested = with_birdnik_url { ExternalChecklist.request_import(callback_url: "http://cb") }

    assert_requested stub
    assert_equal [pending, failed], requested.sort_by(&:id)
    assert_predicate pending.reload, :requested?
    assert_predicate failed.reload, :requested?
    assert_nil failed.error
    assert_predicate no_locus.reload, :pending?
  end

  test "request_import marks checklists failed when Birdnik fails" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 500)

    assert_raises(Birdnik::Client::Error) do
      with_birdnik_url { ExternalChecklist.request_import(callback_url: "http://cb") }
    end
    assert_predicate checklist.reload, :failed?
    assert_equal "Birdnik responded with 500.", checklist.error
  end

  test "request_import keeps checklists imported before Birdnik failed to respond" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return do
      checklist.update!(status: "imported")
      raise Net::ReadTimeout
    end

    assert_raises(Birdnik::Client::Error) do
      with_birdnik_url { ExternalChecklist.request_import(callback_url: "http://cb") }
    end
    assert_predicate checklist.reload, :imported?
  end

  test "import broadcasts status" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))

    checklist.import(checklist_data)

    assert_equal ["imported"], status_broadcasts.pluck("status")
  end

  test "failed import broadcasts status" do
    checklist = create(:external_checklist)

    checklist.import(checklist_data)

    data = status_broadcasts.sole
    assert_equal "failed", data["status"]
    assert_includes data["status_html"], "No locus selected."
  end

  test "request_import broadcasts requested statuses" do
    create_list(:external_checklist, 2, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 202)

    with_birdnik_url { ExternalChecklist.request_import(callback_url: "http://cb") }

    assert_equal %w(requested requested), status_broadcasts.pluck("status")
  end

  test "failed request_import broadcasts failed statuses" do
    create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 500)

    assert_raises(Birdnik::Client::Error) do
      with_birdnik_url { ExternalChecklist.request_import(callback_url: "http://cb") }
    end
    assert_equal %w(requested failed), status_broadcasts.pluck("status")
  end
end

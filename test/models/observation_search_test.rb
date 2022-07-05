# frozen_string_literal: true

require "test_helper"

class ObservationSearchTest < ActiveSupport::TestCase
  setup do
    @cards = [
      create(:card, observ_date: "2013-05-18", locus: loci(:brovary), ebird_id: "S123456789"),
      create(:card, observ_date: "2013-05-18", locus: loci(:kyiv), resolved: false),
      create(:card, observ_date: "2013-05-19", locus: loci(:kyiv)),
    ]
    create(:observation, taxon: taxa(:pasdom), card: @cards[0])
    create(:observation, taxon: taxa(:hirrus), card: @cards[0])
    create(:observation, taxon: taxa(:gargla), card: @cards[0])
    create(:observation, taxon: taxa(:hirrus), card: @cards[1])
    create(:observation, taxon: taxa(:jyntor), card: @cards[1])
    create(:observation, taxon: taxa(:pasdom), card: @cards[2])
    create(:observation, taxon: taxa(:saxola), card: @cards[2])
    create(:observation, taxon: taxa(:gargla_eurasian), card: @cards[2])
  end

  test "search cards by date" do
    assert_equal 2, ObservationSearch.new(observ_date: "2013-05-18").cards.to_a.size
  end

  test "search cards by species" do
    assert_equal 2, ObservationSearch.new(taxon_id: taxa(:pasdom).id).cards.to_a.size
  end

  test "search cards by species including subspecies (default)" do
    assert_equal 2, ObservationSearch.new(taxon_id: taxa(:gargla).id).cards.to_a.size
  end

  test "search cards by species excluding subspecies" do
    assert_equal 1, ObservationSearch.new(taxon_id: taxa(:gargla).id, exclude_subtaxa: true).cards.to_a.size
  end

  test "search cards by species filters only matching observations" do
    cards = ObservationSearch.new(taxon_id: taxa(:pasdom).id).cards.to_a
    assert_equal 1, cards[0].observations.size
  end

  test "search observations by date" do
    obss = ObservationSearch.new(observ_date: "2013-05-18").observations.to_a
    assert_equal 5, obss.size
    assert obss.first.respond_to?(:voice)
  end

  test "search voice: nil means do not filter by voice" do
    ob3 = create(:observation, voice: true)
    assert ObservationSearch.new(voice: nil).observations.include?(ob3)
  end

  test "search voice: false means filter by `seen only`" do
    ob3 = create(:observation, voice: true)
    assert_not_includes ObservationSearch.new(voice: false).observations, ob3
  end

  test "search cards by locus exclusive" do
    assert_equal 2, ObservationSearch.new(locus_id: loci(:kyiv).id).cards.to_a.size
  end

  test "search cards by locus inclusive" do
    assert_equal 3, ObservationSearch.new(locus_id: loci(:ukraine).id, include_subregions: true).cards.to_a.size
  end

  test "search observations by card id should set search locus" do
    obs_search = ObservationSearch.new(card_id: @cards.first.id)
    assert_equal 3, obs_search.observations.to_a.size
    assert_equal @cards.first.locus_id, obs_search.locus_id
  end

  test "search unresolved cards" do
    search = ObservationSearch.new(resolved: false).cards.to_a
    assert_includes search, @cards[1]
    assert_not_includes search, @cards[0]
    assert_not_includes search, @cards[2]
  end
end

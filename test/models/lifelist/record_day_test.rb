# frozen_string_literal: true

require "test_helper"

module Lifelist
  class RecordDayTest < ActiveSupport::TestCase
    def scope
      Observation.identified.joins(:card)
    end

    test "most_species picks the day with the most distinct species" do
      create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2009-05-01"))
      big_day = create(:card, observ_date: "2010-05-02", locus: loci(:nyc))
      create(:observation, taxon: taxa(:pasdom), card: big_day)
      create(:observation, taxon: taxa(:saxola), card: big_day)
      # A repeated species on the same card does not inflate the count
      create(:observation, taxon: taxa(:saxola), card: big_day)

      record = Lifelist::RecordDay.most_species(scope)

      assert_equal Date.new(2010, 5, 2), record.date
      assert_equal 2, record.count
    end

    test "most_species breaks ties by the earliest date" do
      create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-05-02"))
      create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2009-05-01"))

      record = Lifelist::RecordDay.most_species(scope)

      assert_equal Date.new(2009, 5, 1), record.date
      assert_equal 1, record.count
    end

    test "most_lifers counts only first-ever sightings" do
      create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2009-05-01"))
      big_day = create(:card, observ_date: "2010-05-02")
      # hirrus is not a lifer anymore; pasdom and saxola are
      create(:observation, taxon: taxa(:hirrus), card: big_day)
      create(:observation, taxon: taxa(:pasdom), card: big_day)
      create(:observation, taxon: taxa(:saxola), card: big_day)

      record = Lifelist::RecordDay.most_lifers(scope)

      assert_equal Date.new(2010, 5, 2), record.date
      assert_equal 2, record.count
    end

    test "returns nil when there are no observations" do
      assert_nil Lifelist::RecordDay.most_species(scope)
      assert_nil Lifelist::RecordDay.most_lifers(scope)
    end

    test "derives locations and countries from the day's cards" do
      date = "2010-05-02"
      create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: date, locus: loci(:nyc)))
      create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: date, locus: loci(:brovary)))
      # A second card at an already-listed location does not repeat it
      create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: date, locus: loci(:nyc)))

      record = Lifelist::RecordDay.most_species(scope)

      assert_equal ["Нью-Йорк", "Бровари"], record.locations.map(&:name)
      assert_equal ["США", "Україна"], record.countries.map(&:name)
    end

    test "groups locations by subdivision and country" do
      date = "2010-05-02"
      create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: date, locus: loci(:nyc)))
      create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: date, locus: loci(:brovary)))
      create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: date, locus: loci(:kyiv)))

      groups = Lifelist::RecordDay.most_species(scope).grouped_locations

      assert_equal ["США", "Україна"], groups.map { |country, _| country.name }
      usa_regions = groups.first.last
      assert_equal ["шт. Нью-Йорк"], usa_regions.map { |region, _| region.name }
      assert_equal [["Нью-Йорк"]], usa_regions.map { |_, locs| locs.map(&:name) }
      # Kyiv has no cached subdivision, so it forms its own group
      ukraine_regions = groups.last.last
      assert_equal ["Київська обл.", nil], ukraine_regions.map { |region, _| region&.name }
      assert_equal [["Бровари"], ["Київ"]], ukraine_regions.map { |_, locs| locs.map(&:name) }
    end

    test "finds the localized post attached to the day's cards" do
      date = "2010-05-02"
      post = create(:post, lang: "uk")
      card = create(:card, observ_date: date, locus: loci(:nyc), post_core: post.post_core)
      create(:observation, taxon: taxa(:pasdom), card: card)

      record = Lifelist::RecordDay.most_species(scope)

      assert_equal post, record.post(:uk)
      assert_nil record.post(:en)
    end
  end
end

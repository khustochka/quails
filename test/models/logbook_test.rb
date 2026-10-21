# frozen_string_literal: true

require "test_helper"

class LogbookTest < ActiveSupport::TestCase
  def observe(taxon, date, locus = :brovary, **attrs)
    create(:observation, taxon: taxa(taxon), card: create(:card, observ_date: date, locus: loci(locus)), **attrs)
  end

  def enable(locus, life: true, year: true)
    LogbookSetting.create!(locus: locus && loci(locus), life: life, year: year)
  end

  def summary(result)
    result.map do |date, entries|
      [date.iso8601, entries.map { |e| [e.type, e.locus&.slug, e.year, e.list_total, e.covered.map { |l, t| [l.slug, t] }] }]
    end
  end

  test "no entries without settings" do
    observe(:pasdom, "2024-05-01")

    assert_empty Logbook.new.for_year(2024)
  end

  test "lifer is reported for the World and covers the life lists of enabled areas" do
    enable(nil)
    enable(:ukraine)
    observe(:pasdom, "2024-05-01")

    assert_equal [["2024-05-01", [[:life, nil, nil, 1, [["ukraine", 1]]]]]], summary(Logbook.new.for_year(2024))
  end

  test "lifer is reported for the area when World life list is disabled" do
    enable(nil, life: false, year: false)
    enable(:ukraine, year: false)
    observe(:pasdom, "2024-05-01")

    assert_equal [["2024-05-01", [[:life, "ukraine", nil, 1, []]]]], summary(Logbook.new.for_year(2024))
  end

  test "species new for an area is reported for that area" do
    enable(nil)
    enable(:usa)
    observe(:pasdom, "2024-05-01")
    observe(:pasdom, "2024-06-01", :new_york)

    assert_equal ["2024-06-01", [[:life, "usa", nil, 1, []]]], summary(Logbook.new.for_year(2024)).assoc("2024-06-01")
  end

  test "year addition is reported when the species is not a lifer" do
    enable(nil)
    observe(:pasdom, "2023-05-01")
    observe(:pasdom, "2024-02-01")

    assert_equal [["2024-02-01", [[:year, nil, 2024, 1, []]]]], summary(Logbook.new.for_year(2024))
  end

  test "area year addition is covered by the World year addition on the same day" do
    enable(nil)
    enable(:ukraine)
    observe(:pasdom, "2023-05-01")
    observe(:pasdom, "2024-02-01")

    assert_equal [["2024-02-01", [[:year, nil, 2024, 1, []]]]], summary(Logbook.new.for_year(2024))
  end

  test "area year addition is reported after the World one" do
    enable(nil)
    enable(:ukraine)
    observe(:pasdom, "2023-05-01")
    observe(:pasdom, "2024-02-01", :new_york)
    observe(:pasdom, "2024-04-01", :kyiv)

    assert_equal [["2024-02-01", [[:year, nil, 2024, 1, []]]], ["2024-04-01", [[:year, "ukraine", 2024, 1, []]]]],
      summary(Logbook.new.for_year(2024))
  end

  test "species added together are grouped into one entry" do
    enable(nil)
    first = observe(:pasdom, "2024-05-01")
    second = observe(:hirrus, "2024-05-01")

    entries = Logbook.new.for_year(2024).first.last

    assert_equal 1, entries.size
    assert_equal [first, second].to_set, entries.first.observations.to_set
    assert_equal 2, entries.first.list_total
  end

  test "earlier observation on the same day defines the order and totals" do
    enable(nil)
    observe(:pasdom, "2024-05-01")
    create(:observation, taxon: taxa(:pasdom),
      card: create(:card, observ_date: "2024-05-01", start_time: "06:00", locus: loci(:kyiv)))

    entry = Logbook.new.for_year(2024).first.last.first

    assert_equal 1, entry.observations.size
    assert_equal "kyiv", entry.observations.first.card.locus.slug
  end

  test "species are ordered and counted as numbered in the lifelist" do
    enable(nil)
    timed = create(:observation, taxon: taxa(:pasdom),
      card: create(:card, observ_date: "2024-05-01", start_time: "08:00"))
    untimed1 = observe(:hirrus, "2024-05-01")
    untimed2 = observe(:jyntor, "2024-05-01")
    observe(:bomgar, "2024-04-01")

    lifelist = Lifelist::FirstSeen.full.to_a
    numbers = lifelist.each_with_index.to_h { |obs, i| [obs.species_id, lifelist.size - i] }
    entry = Logbook.new.for_year(2024).assoc(Date.new(2024, 5, 1)).last.first

    assert_equal [untimed1, untimed2, timed], entry.observations
    assert_equal [2, 3, 4], entry.observations.map { |obs| numbers[obs.species_id] }
    assert_equal 4, entry.list_total
  end

  test "recent lists dates newest first, limited and cut off" do
    enable(nil)
    observe(:pasdom, 10.days.ago.to_date)
    observe(:hirrus, 5.days.ago.to_date)
    observe(:jyntor, 1.day.ago.to_date)

    assert_equal [1.day.ago.to_date, 5.days.ago.to_date], Logbook.new.recent(limit: 2).map(&:first)
    assert_equal [1.day.ago.to_date, 5.days.ago.to_date], Logbook.new.recent(cutoff_days: 7).map(&:first)
  end

  test "for_year lists dates of that year oldest first" do
    enable(nil)
    observe(:pasdom, "2023-12-31")
    observe(:hirrus, "2024-03-01")
    observe(:jyntor, "2024-01-01")

    assert_equal [Date.new(2024, 1, 1), Date.new(2024, 3, 1)], Logbook.new.for_year(2024).map(&:first)
  end

  test "observation scope is respected" do
    enable(nil)
    observe(:pasdom, "2024-05-01", hidden: true)

    assert_empty Logbook.new(observation_scope: Observation.not_hidden).for_year(2024)
    assert_equal 1, Logbook.new.for_year(2024).size
  end
end

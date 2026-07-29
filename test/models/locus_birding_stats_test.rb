# frozen_string_literal: true

require "test_helper"

class LocusBirdingStatsTest < ActiveSupport::TestCase
  def entry_for(locus)
    LocusBirdingStats.all.find { |e| e.id == locus.id }
  end

  test "reports card count and species indexes per locus" do
    locus = create(:locus, lat: 50.0, lon: 30.0)
    card = create(:card, locus: locus)
    create(:observation, card: card, taxon: taxa(:pasdom))
    create(:observation, card: card, taxon: taxa(:hirrus))

    entry = entry_for(locus)
    assert_equal 1, entry.cards
    assert_equal [species(:hirrus).index_num, species(:pasdom).index_num].sort, entry.species_indexes
  end

  test "counts each species once across several cards" do
    locus = create(:locus, lat: 50.0, lon: 30.0)
    2.times do |i|
      card = create(:card, locus: locus, observ_date: "2010-06-1#{i}")
      create(:observation, card: card, taxon: taxa(:pasdom))
    end

    entry = entry_for(locus)
    assert_equal 2, entry.cards
    assert_equal [species(:pasdom).index_num], entry.species_indexes
  end

  test "includes a visited locus with no identified species" do
    locus = create(:locus, lat: 50.0, lon: 30.0)
    create(:card, locus: locus)

    entry = entry_for(locus)
    assert_equal 1, entry.cards
    assert_empty entry.species_indexes
  end

  test "excludes loci without coordinates and without cards" do
    no_coords = create(:locus, lat: nil, lon: nil)
    create(:card, locus: no_coords)
    unvisited = create(:locus, lat: 51.0, lon: 31.0)

    ids = LocusBirdingStats.all.map(&:id)
    assert_not_includes ids, no_coords.id
    assert_not_includes ids, unvisited.id
  end

  test "excludes loci missing either coordinate" do
    no_lon = create(:locus, lat: 50.0, lon: nil)
    create(:card, locus: no_lon)
    no_lat = create(:locus, lat: nil, lon: 30.0)
    create(:card, locus: no_lat)

    ids = LocusBirdingStats.all.map(&:id)
    assert_not_includes ids, no_lon.id
    assert_not_includes ids, no_lat.id
  end

  test "rolls a private locus up to its public ancestor" do
    city = create(:locus, lat: 50.0, lon: 30.0, loc_type: "city")
    site = create(:locus, lat: 50.5, lon: 30.5, parent: city, private_loc: true, loc_type: "site")
    create(:observation, card: create(:card, locus: site), taxon: taxa(:pasdom))

    assert_nil entry_for(site)

    entry = entry_for(city)
    assert_equal 1, entry.cards
    assert_in_delta 50.0, entry.lat
    assert_in_delta 30.0, entry.lon
    assert_equal [species(:pasdom).index_num], entry.species_indexes
  end

  test "merges a private locus into its public ancestor's own totals" do
    city = create(:locus, lat: 50.0, lon: 30.0, loc_type: "city")
    site = create(:locus, lat: 50.5, lon: 30.5, parent: city, private_loc: true, loc_type: "site")
    create(:observation, card: create(:card, locus: city), taxon: taxa(:pasdom))
    create(:observation, card: create(:card, locus: site), taxon: taxa(:hirrus))

    entry = entry_for(city)
    assert_equal 2, entry.cards
    assert_equal [species(:hirrus).index_num, species(:pasdom).index_num].sort, entry.species_indexes
  end

  test "counts a species seen at both a private locus and its ancestor once" do
    city = create(:locus, lat: 50.0, lon: 30.0, loc_type: "city")
    site = create(:locus, lat: 50.5, lon: 30.5, parent: city, private_loc: true, loc_type: "site")
    create(:observation, card: create(:card, locus: city), taxon: taxa(:pasdom))
    create(:observation, card: create(:card, locus: site), taxon: taxa(:pasdom))

    entry = entry_for(city)
    assert_equal 2, entry.cards
    assert_equal [species(:pasdom).index_num], entry.species_indexes
  end

  test "drops a private locus whose public ancestor has no coordinates" do
    region = create(:locus, lat: nil, lon: nil, loc_type: "subdivision1")
    site = create(:locus, lat: 50.5, lon: 30.5, parent: region, private_loc: true, loc_type: "site")
    create(:observation, card: create(:card, locus: site), taxon: taxa(:pasdom))

    ids = LocusBirdingStats.all.map(&:id)
    assert_not_includes ids, site.id
    assert_not_includes ids, region.id
  end

  test "species_index_size covers the highest species index" do
    assert_operator LocusBirdingStats.species_index_size, :>, Species.maximum(:index_num)
  end

  test "serialises the fields the map needs" do
    locus = create(:locus, lat: 50.0, lon: 30.0)
    create(:observation, card: create(:card, locus: locus), taxon: taxa(:pasdom))

    json = entry_for(locus).as_json
    assert_equal locus.slug, json[:slug]
    assert_in_delta(50.0, json[:lat])
    assert_in_delta(30.0, json[:lon])
    assert_equal 1, json[:cards]
    assert_equal [species(:pasdom).index_num], json[:species]
  end
end

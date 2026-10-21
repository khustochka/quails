# frozen_string_literal: true

require "test_helper"

class LogbookHelperTest < ActionView::TestCase
  helper SpeciesHelper

  def entry(type:, locus: nil, year: nil, count: 1, covered: [])
    Logbook::Entry.new(type: type, locus: locus, year: year, observations: Array.new(count) { Observation.new },
      list_total: 10, covered: covered)
  end

  def label(**)
    Nokogiri::HTML.fragment(logbook_entry_label(entry(**))).text
  end

  test "single species labels" do
    assert_equal "New lifer (10)", label(type: :life)
    assert_equal "New species in Ukraine (10)", label(type: :life, locus: loci(:ukraine))
    assert_equal "New species for 2024 (10)", label(type: :year, year: 2024)
    assert_equal "New for Ukraine 2024 (10)", label(type: :year, locus: loci(:ukraine), year: 2024)
  end

  test "multiple species labels" do
    assert_equal "Added 2 new lifers (10)", label(type: :life, count: 2)
    assert_equal "Added 2 new species in Ukraine (10)", label(type: :life, locus: loci(:ukraine), count: 2)
    assert_equal "Added 2 new species for 2024 (10)", label(type: :year, year: 2024, count: 2)
    assert_equal "Added 2 new species for Ukraine 2024 (10)",
      label(type: :year, locus: loci(:ukraine), year: 2024, count: 2)
  end

  test "covered areas are appended" do
    assert_equal "New lifer (10), new species in Ukraine (3), new species in Kyiv oblast (2)",
      label(type: :life, covered: [[loci(:ukraine), 3], [loci(:kiev_obl), 2]])
  end

  test "World lifer species are emphasized" do
    species = taxa(:pasdom).species
    lifer = Logbook::Entry.new(type: :life, observations: [Observation.new(species: species)], covered: [])
    area_lifer = Logbook::Entry.new(type: :life, locus: loci(:ukraine), observations: [Observation.new(species: species)],
      covered: [])

    assert Nokogiri::HTML.fragment(logbook_species(lifer)).at("strong a.sp_link")
    assert_nil Nokogiri::HTML.fragment(logbook_species(area_lifer)).at("strong")
  end

  test "World lifer entries have a star" do
    assert Nokogiri::HTML.fragment(logbook_entry_label(entry(type: :life))).at(".fa-star[aria-hidden=true]")
    assert_nil Nokogiri::HTML.fragment(logbook_entry_label(entry(type: :life, locus: loci(:ukraine)))).at(".fa-star")
    assert_nil Nokogiri::HTML.fragment(logbook_entry_label(entry(type: :year, year: 2024))).at(".fa-star")
  end

  test "totals link to species anchors in lifelists" do
    html = Nokogiri::HTML.fragment(logbook_entry_label(entry(type: :year, locus: loci(:ukraine), year: 2024)))

    assert_equal "/lifelist/ukraine/2024#lifer-10", html.at("a")["href"]
  end
end

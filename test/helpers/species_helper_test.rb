# frozen_string_literal: true

require "test_helper"

class SpeciesHelperTest < ActionView::TestCase
  test "other name locales are listed with the current one left out" do
    assert_equal %w(en fr ru), I18n.with_locale(:uk) { species_name_locales }
    assert_equal %w(uk fr ru), I18n.with_locale(:en) { species_name_locales }
    assert_equal %w(uk en fr), I18n.with_locale(:ru) { species_name_locales }
  end

  test "avibase url carries the id and the language" do
    assert_includes avibase_species_url("ABC123"), "avibaseid=ABC123"
    assert_includes avibase_species_url("ABC123"), "lang=EN"
    assert_includes avibase_species_url("ABC123", "RU"), "lang=RU"
  end

  test "scientific name is rendered in italics and marked as latin" do
    result = name_sci(species(:pasdom))

    assert_includes result, "Passer domesticus"
    assert_includes result, %(lang="la")
    assert_includes result, "<i"
  end

  test "unknown species shows the given text with the scientific name as a title" do
    result = unknown_species("some sparrow", "Passer sp.")

    assert_includes result, "some sparrow"
    assert_includes result, %(title="Passer sp.")
  end

  test "unknown species falls back to the scientific name when there is no text" do
    result = unknown_species("", "Passer sp.")

    assert_includes result, "Passer sp."
    assert_includes result, "sci_name"
  end

  test "term highlight wraps the matching part" do
    result = term_highlight("House Sparrow", "Sparrow")

    assert_includes result, %(<span class="highlight">Sparrow</span>)
  end

  test "term highlight leaves a non-matching string alone" do
    assert_equal "House Sparrow", term_highlight("House Sparrow", "Eagle")
  end

  class MapLocus < Struct.new(:lat, :lon); end

  test "species map rounds marker coordinates and drops the ones without a position" do
    result = species_map("ukraine", [MapLocus.new(50.451234, 30.523456), MapLocus.new(nil, nil)])

    assert_includes result, "markers=50.45,30.52"
  end

  test "species map collapses loci that round to the same point" do
    loci = [MapLocus.new(50.4512, 30.5234), MapLocus.new(50.4531, 30.5249), MapLocus.new(49.99, 36.23)]

    result = species_map("ukraine", loci)

    assert_includes result, "markers=50.45,30.52|49.99,36.23"
  end

  test "species map zooms out automatically when the loci are far apart" do
    loci = [MapLocus.new(10.0, 10.0), MapLocus.new(40.0, 60.0)]

    assert_includes species_map("canada", loci), "zoom=&"
    assert_includes species_map("canada", [MapLocus.new(10.0, 10.0)]), "zoom=5"
  end
end

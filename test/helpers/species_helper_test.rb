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
end

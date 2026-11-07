# frozen_string_literal: true

require "test_helper"
require_relative "taxonomy_csv_helper"

class Quails::TaxonomyUpdate::DifferTest < ActiveSupport::TestCase
  include TaxonomyCsvHelper

  setup do
    @rows = current_ebird_rows
  end

  test "no entries when nothing changed" do
    assert_empty diff.entries
  end

  test "renames only what eBird changed" do
    species(:hirrus).update!(name_en: "Swallow")
    @rows["barswa"].merge!("sci_name" => "Hirundo novus", "primary_com_name" => "Barn Swallow")
    @rows["houspa"]["primary_com_name"] = "Common House Sparrow"

    entries = diff.entries.index_by { |e| e[:code] }

    assert_equal({ old: "Hirundo rustica", new: "Hirundo novus" }, entries["barswa"][:name_sci])
    assert_nil entries["barswa"][:name_en]
    assert_equal({ old: "House Sparrow", new: "Common House Sparrow", accept: true }, entries["houspa"][:name_en])
  end

  test "hyphenation-only English rename is not accepted by default" do
    species(:hirrus).update!(name_en: "Barn Swallow")
    @rows["barswa"]["primary_com_name"] = "Barn-Swallow"
    entry = diff.entries.sole

    assert_not entry[:name_en][:accept]
  end

  test "split into a slash finds daughters through subspecies and name" do
    create(:observation, taxon: taxa(:hirrus))
    @rows["barswa"].merge!("category" => "slash", "sci_name" => "Hirundo rustica/erythrogaster")
    @rows["barswa5"].merge!("category" => "species", "sci_name" => "Hirundo erythrogaster", "sparse_report_as" => nil)
    add_row("barswa9", "species", "Hirundo rustica")

    entry = diff.entries.sole

    assert_equal "split", entry[:type]
    assert_equal({ "barswa5" => "children", "barswa9" => "name" }, entry[:daughters].to_h { |d| [d[:code], d[:matched_by]] })
    assert_equal "barswa9", entry[:survivor]
    assert_equal 1, entry[:observation_count]
  end

  test "split where the old code survives is detected by concept change" do
    ebird_taxa(:gargla).update!(taxon_concept_id: "avibase-AAAA")
    @rows["eurjay1"]["bio_concept_code"] = "avibase-BBBB"
    @rows["eurjay2"].merge!("category" => "species", "sci_name" => "Garrulus novus", "sparse_report_as" => nil)

    entry = diff.entries.sole

    assert_equal "split", entry[:type]
    assert_equal %w[eurjay1 eurjay2], entry[:daughters].pluck(:code)
    assert_equal "eurjay1", entry[:survivor]
  end

  test "split where the new species only appears in a new slash" do
    ebird_taxa(:gargla).update!(taxon_concept_id: "avibase-AAAA")
    @rows["eurjay1"]["bio_concept_code"] = "avibase-BBBB"
    add_row("y00001", "slash", "Garrulus glandarius/novus")
    add_row("newjay1", "species", "Garrulus novus")

    entry = diff.entries.sole

    assert_equal "split", entry[:type]
    assert_equal({ "eurjay1" => "code", "newjay1" => "slash" }, entry[:daughters].to_h { |d| [d[:code], d[:matched_by]] })
    assert_equal "eurjay1", entry[:survivor]
  end

  test "concept change without new species is flagged for review" do
    ebird_taxa(:hirrus).update!(taxon_concept_id: "avibase-AAAA")
    @rows["barswa"]["bio_concept_code"] = "avibase-BBBB"

    assert_equal "concept_change", diff.entries.sole[:type]
  end

  test "lump into a species I have keeps that species" do
    @rows["barswa"].merge!("category" => "issf", "sparse_report_as" => "houspa")

    entry = diff.entries.sole

    assert_equal "lump", entry[:type]
    assert_equal "houspa", entry[:into]
    assert_equal ["Hirundo rustica"], entry[:species]
    assert_equal "Passer domesticus", entry[:survivor]
  end

  test "removed code with the same concept elsewhere is a code change" do
    ebird_taxa(:hirrus).update!(taxon_concept_id: "avibase-AAAA")
    @rows.delete("barswa")
    @rows["barswa5"]["sparse_report_as"] = "barswa2"
    add_row("barswa2", "species", "Hirundo rustica", concept: "AAAA")

    entry = diff.entries.sole

    assert_equal "code_change", entry[:type]
    assert_equal "barswa2", entry[:new_code]
  end

  test "removed subspecies with observations needs a new home" do
    gargla_eurasian = taxa(:gargla_eurasian)
    create(:observation, taxon: gargla_eurasian)
    @rows.delete("eurjay2")

    entry = diff.entries.sole

    assert_equal({ type: "ambiguous", code: "eurjay2", observation_count: 1 }, entry.slice(:type, :code, :observation_count))
  end

  test "species kept above eBird rank are not reported as lumps" do
    assert_equal "issf", ebird_taxa(:motfel).category
    @rows["weywag6"]["primary_com_name"] = "Changed"

    assert_empty diff.entries
  end

  private

  def add_row(code, category, name_sci, concept: nil)
    @rows[code] = ebird_row(code, category, name_sci, concept: concept)
  end

  def diff
    Quails::TaxonomyUpdate::Differ.new(taxonomy_source(@rows))
  end
end

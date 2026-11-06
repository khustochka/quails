# frozen_string_literal: true

require "test_helper"

class Quails::TaxonomyUpdate::SourceTest < ActiveSupport::TestCase
  CSV_2025 = <<~CSV
    ﻿TAXON_ORDER,CATEGORY,SPECIES_CODE,TAXON_CONCEPT_ID,PRIMARY_COM_NAME,SCI_NAME,ORDER,FAMILY,SPECIES_GROUP,REPORT_AS
    1,species,houspa,avibase-avibase-240E3390,House Sparrow,Passer domesticus,Passeriformes,Passeridae,Old World Sparrows,
    2,issf,houspa13,avibase-avibase-C71FD145,House Sparrow (Gray-cheeked),Passer domesticus [domesticus Group],Passeriformes,Passeridae,Old World Sparrows,houspa
  CSV

  CSV_2026 = <<~CSV
    ﻿taxon_order,category,species_code,bio_concept_code,primary_com_name,sci_name,order1,family,species_group,sparse_report_as,report_as,four_letter_code,extinct,extinct_year
    1,species,houspa,avibase-240E3390,House Sparrow,Passer domesticus,Passeriformes,Passeridae,Old World Sparrows,,houspa,HOSP,0,
    2,issf,houspa13,avibase-C71FD145,House Sparrow (Gray-cheeked),Passer domesticus [domesticus Group],Passeriformes,Passeridae,Old World Sparrows,houspa,houspa,,0,
  CSV

  test "reads both header layouts into the same rows" do
    old = Quails::TaxonomyUpdate::Source.new(CSV_2025)
    new = Quails::TaxonomyUpdate::Source.new(CSV_2026)

    assert_equal old.rows, new.rows
    row = new["houspa13"]
    assert_equal "240E3390", new["houspa"].concept
    assert_equal "C71FD145", row.concept
    assert_equal "houspa", row.parent_code
    assert_nil new["houspa"].parent_code
  end

  test "resolves the reporting species and concept lookups" do
    source = Quails::TaxonomyUpdate::Source.new(CSV_2026)

    assert_equal "houspa", source.species_for("houspa13").code
    assert_equal ["houspa"], source.with_concept("avibase-avibase-240E3390").map(&:code)
    assert_equal ["houspa13"], source.children_of("houspa").map(&:code)
  end

  test "expands slash names between binomials only" do
    assert_equal ["Tringa semipalmata", "Tringa inornata"], Quails::TaxonomyUpdate::Source.slash_names("Tringa semipalmata/inornata")
    assert_equal ["Larus fuscus", "Ichthyaetus audouinii"], Quails::TaxonomyUpdate::Source.slash_names("Larus fuscus/Ichthyaetus audouinii")
    assert_empty Quails::TaxonomyUpdate::Source.slash_names("Aerospiza/Tachyspiza sp.")
  end

  test "rejects a CSV missing a required column" do
    assert_raises(ArgumentError) { Quails::TaxonomyUpdate::Source.new("species_code,category\nhouspa,species\n") }
  end
end

# frozen_string_literal: true

namespace :tax do
  # desc "Import ebird taxa to taxa and ebird_taxa tables"
  task import_ebird_taxa: :environment do
    filename = ENV["CSV"] || "./data/eBird_Taxonomy_v2016.csv"

    raise "*** Provide path to ebird CSV as CSV env var." if filename.blank?

    puts "\n********** Import taxa from ebird from `#{filename}`"

    if Taxon.count > 0 || EBirdTaxon.count > 0
      raise "Taxa tables not empty"
    end

    require "csv"

    codes = {}

    # EBird File is in some Mac encoding, and not all of them are convertable to UTF-8.
    # This one works for now (check Rüppell's Warbler)
    # 2016: Fixed sci name for Red-billed Curassow to Crax blumenbachii
    data = CSV.read(filename, encoding: "macRoman:UTF-8")
    data.shift # skip headers
    data.each_with_index do |(ebird_order, category, code, name_en, name_ioc, name_sci, order, family, _, report_as), idx|
      e_taxon = EBirdTaxon.create!(
          name_sci: name_sci,
          name_en: name_en,
          name_ioc_en: name_ioc,
          ebird_code: code,
          category: category,
          order: order,
          family: family,
          ebird_order_num_str: ebird_order,
          parent_id: codes[report_as].try(:[], 0),
          index_num: idx + 1
      )
      taxon = Taxon.create!(
          name_sci: name_sci,
          name_en: name_en,
          ebird_code: code,
          category: category,
          order: order,
          family: family,
          ebird_taxon_id: e_taxon.id,
          parent_id: codes[report_as].try(:[], 1),
          index_num: idx + 1
      )
      codes[code] = [e_taxon.id, taxon.id]
    end

    # Raise some subspecies to species
    [
        ["Cygnus columbianus bewickii", "Cygnus bewickii", "Bewick's Swan", "tunswa2"],
        ["Larus fuscus heuglini", "Larus heuglini", "Heuglin's Gull", "slbgul"],
        ["Motacilla flava feldegg", "Motacilla feldegg", "Black-headed Wagtail", "eaywag"]
    ].each do |ssp_name, sp_name, en_name, idx_next|
      motfel = Taxon.find_by_name_sci(ssp_name)
      motfel.update(
          name_sci: sp_name,
          name_en: en_name,
          category: "species",
          parent_id: nil,
          index_num: Taxon.find_by_ebird_code(idx_next).index_num - 1
      )
    end
  end
end

# frozen_string_literal: true

# Builds eBird taxonomy CSVs from the current ebird_taxa, for tests to edit row by row.
module TaxonomyCsvHelper
  CSV_HEADER = %w[taxon_order category species_code bio_concept_code primary_com_name sci_name order1 family sparse_report_as].freeze

  def current_ebird_rows
    EBirdTaxon.order(:index_num).preload(:parent).to_h do |et|
      [et.ebird_code, {
        "taxon_order" => et.index_num, "category" => et.category, "species_code" => et.ebird_code,
        "bio_concept_code" => et.taxon_concept_id, "primary_com_name" => et.name_en, "sci_name" => et.name_sci,
        "order1" => et.order, "family" => et.family, "sparse_report_as" => et.parent&.ebird_code,
      },]
    end
  end

  def ebird_row(code, category, name_sci, concept: nil, parent: nil)
    { "category" => category, "species_code" => code, "bio_concept_code" => concept,
      "primary_com_name" => code, "sci_name" => name_sci, "sparse_report_as" => parent, }
  end

  # Rows are written in hash order, which becomes the taxonomic order.
  def taxonomy_source(rows)
    csv = CSV.generate do |out|
      out << CSV_HEADER
      rows.each_value { |row| out << CSV_HEADER.map { |h| row[h] } }
    end
    Quails::TaxonomyUpdate::Source.new(csv)
  end
end

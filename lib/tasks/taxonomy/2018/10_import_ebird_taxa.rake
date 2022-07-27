# frozen_string_literal: true

namespace :tax do
  namespace :update2018 do
    task import_ebird_taxa: [:import_ebird_csv, :fix_taxa_links_to_ebird, :clean_ebird_taxa]

    task import_ebird_csv: :environment do
      filename = ENV["CSV"] || "./data/eBird_Taxonomy_v2018_14Aug2018.csv"

      raise "*** Provide path to ebird CSV as CSV env var." if filename.blank?

      puts "\n********** Importing EBird taxa from `#{filename}`"

      require "csv"

      codes = {}

      all_etaxa = EBirdTaxon.all.index_by(&:ebird_code)

      # EBird File is in some Mac encoding, and not all of them are convertable to UTF-8.
      # This one works for now (check Rüppell's Warbler)
      data = CSV.read(filename, encoding: "macRoman:UTF-8")
      data.shift # skip headers

      # Why we need this workaround? Because we cache the taxa. And then we change their order.
      # But the index_num's in the cached models are different from the real ones (after previous taxa are moved up or down.)
      # This causes problems, duplicated and missing indices.
      EBirdTaxon.acts_as_list_no_update do
        data.each_with_index do |(ebird_order, category, code, name_en, name_sci, order, family, _, report_as), idx|
          e_taxon = all_etaxa[code] || EBirdTaxon.new(ebird_code: code)
          e_taxon.update!(
              name_sci: name_sci,
              name_en: name_en,
              category: category,
              order: order,
              family: family,
              ebird_order_num_str: ebird_order,
              parent_id: codes[report_as],
              ebird_version: 2018,
              index_num: idx + 1
          )
          codes[code] = e_taxon.id
        end
      end

      old_etaxa = EBirdTaxon.where(ebird_version: 2017)
      to_fix = Taxon.joins(:ebird_taxon).merge(old_etaxa)
      num_to_fix = to_fix.count
      puts "\n\nREPORT:"
      puts "Number of 2017 taxa left: #{old_etaxa.count}"
      puts "Number of my taxa referencing those: #{num_to_fix}\n\n"
      if num_to_fix == 0
        puts "Nothing to fix"
      else
        puts "To fix:"
        puts to_fix.map(&:name_sci).join(", ")
      end
    end

    task fix_taxa_links_to_ebird: :environment do
      common_firecrest = EBirdTaxon.find_by(ebird_code: "firecr1")
      Taxon.find_by(ebird_code: "firecr2").update!(
          ebird_code: "firecr1",
          ebird_taxon: common_firecrest
      )
    end

    task clean_ebird_taxa: :environment do
      old_etaxa = EBirdTaxon.where(ebird_version: 2017)
      to_fix = Taxon.joins(:ebird_taxon).merge(old_etaxa)
      num_to_fix = to_fix.count
      puts "\n\nREPORT:"
      puts "Number of 2017 taxa left: #{old_etaxa.count}"
      puts "Number of my taxa referencing those: #{num_to_fix}\n\n"
      if num_to_fix == 0
        old_etaxa.delete_all
        puts "Old ebird taxa removed."
      else
        puts "To fix:"
        puts to_fix.map(&:name_sci).join(", ")
        puts "Fix the taxa in `fix_taxa` task"
      end
    end
  end
end

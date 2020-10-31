# frozen_string_literal: true

namespace :tax do
  namespace :update2017 do
    task import_ebird_taxa: :environment do
      filename = ENV["CSV"] || "./data/eBird_Taxonomy_v2017_18Aug2017.csv"

      raise "*** Provide path to ebird CSV as CSV env var." if filename.blank?

      puts "\n********** Importing EBird taxa from `#{filename}`"

      require "csv"

      codes = {}


      # Why we need this workaround? Because we cache the taxa. And then we change their order.
      # But the index_num's in the cached models are different from the real ones (after previous taxa are moved up or down.)
      # This causes problems, duplicated and missing indices.
      # TODO: This may need rework after we switch from ordered-active-record to acts_as_positioned
      # TODO 2018: I have switched to acts_as_list gem, which can be disabled for mass update:
      # TodoItem.acts_as_list_no_update do
      #   .....
      # end
      EbirdTaxon.update_all(index_num: 0)

      all_etaxa = EbirdTaxon.all.index_by(&:ebird_code)

      # Ebird File is in some Mac encoding, and not all of them are convertable to UTF-8.
      # This one works for now (check Rüppell's Warbler)
      data = CSV.read(filename, encoding: "macRoman:UTF-8")
      data.shift # skip headers
      data.each_with_index do |(ebird_order, category, code, name_en, name_sci, order, family, _, report_as), idx|
        e_taxon = all_etaxa[code] || EbirdTaxon.new(ebird_code: code)
        e_taxon.update!(
            name_sci: name_sci,
            name_en: name_en,
            # ioc name was removed from the csv
            #name_ioc_en: name_ioc,
            category: category,
            order: order,
            family: family,
            ebird_order_num_str: ebird_order,
            parent_id: codes[report_as],
            ebird_version: 2017,
            index_num: 0 # workaround
        )
        e_taxon.update_column(:index_num, idx + 1) # to prevent costly reordering
        codes[code] = e_taxon.id
      end

      old_etaxa = EbirdTaxon.where(ebird_version: 2016)
      num_to_fix = Taxon.joins(:ebird_taxon).merge(old_etaxa).count
      puts "\n\nREPORT:"
      puts "Number of 2016 taxa left: #{old_etaxa.count}"
      puts "Number of my taxa joined with those: #{num_to_fix}\n\n"
      if num_to_fix == 0
        old_etaxa.delete_all
      end
    end

    task find_discrepancies: :environment do
      taxa_rank = Taxon.joins(:ebird_taxon).includes(:ebird_taxon).where("taxa.category != ebird_taxa.category")

      puts "RANK CHANGED:\n\n"

      taxa_rank.each do |tx|
        puts "#{tx.name_sci} (#{tx.category})"
        puts "               - changed to #{tx.ebird_taxon.category} (#{tx.ebird_taxon.name_sci})"
      end

      taxa_sci = Taxon.joins(:ebird_taxon).includes(:ebird_taxon).where("taxa.name_sci != ebird_taxa.name_sci")

      puts "\n\nSCIENTIFIC NAME CHANGED:\n\n"

      taxa_sci.each do |tx|
        puts "#{tx.name_sci} (#{tx.category})"
        puts "               - changed to #{tx.ebird_taxon.name_sci} (#{tx.ebird_taxon.category})"
      end

      taxa_name = Taxon.joins(:ebird_taxon).includes(:ebird_taxon).where("taxa.name_en != ebird_taxa.name_en")

      puts "\n\nENGLISH NAME CHANGED:\n\n"

      taxa_name.each do |tx|
        puts "#{tx.name_sci} (#{tx.name_en})"
        puts "               - changed to #{tx.ebird_taxon.name_sci} (#{tx.ebird_taxon.name_en})"
      end
    end
  end
end

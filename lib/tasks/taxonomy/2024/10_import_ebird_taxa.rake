# frozen_string_literal: true

namespace :tax do
  namespace :update2024 do
    task import_ebird_taxa: [:import_ebird_csv, :list_rank_changes, :fix_removed_codes, :clean_ebird_taxa]

    task import_ebird_csv: :environment do
      filename = ENV["CSV"] || "./data/eBird_Taxonomy_v2024.csv"

      raise "*** Provide path to eBird CSV as CSV env var." if filename.blank?

      puts "\n********** Importing eBird taxa from `#{filename}`"

      require "csv"

      codes = {}

      all_etaxa = EBirdTaxon.all.index_by(&:ebird_code)

      # EBird File is in some Mac encoding, and not all of them are convertable to UTF-8.
      # This one works for now (check Rüppell's Warbler)
      # I have fixed encoding in RubyMine (selected Mac Central European)
      #data = CSV.read(filename, encoding: "macRoman:UTF-8")
      data = CSV.read(filename)
      data.shift # skip headers

      # Why we need this workaround? Because we cache the taxa. And then we change their order.
      # But the index_num's in the cached models are different from the real ones (after previous taxa are moved up or down.)
      # This causes problems, duplicated and missing indices.
      EBirdTaxon.acts_as_list_no_update do
        data.each_with_index do |(ebird_order, category, code, taxon_concept_id, name_en, name_sci, order, family, _, report_as), idx|
          e_taxon = all_etaxa[code] || EBirdTaxon.new(ebird_code: code)
          e_taxon.update!(
              name_sci: name_sci,
              name_en: name_en,
              category: category,
              order: order,
              family: family,
              taxon_concept_id: taxon_concept_id,
              ebird_order_num_str: ebird_order,
              parent_id: codes[report_as],
              ebird_version: 2024,
              index_num: idx + 1
          )
          codes[code] = e_taxon.id
        end
      end
    end

    task :list_rank_changes => :environment do
      taxa_rank = Taxon.joins("LEFT OUTER JOIN ebird_taxa ON taxa.ebird_code = ebird_taxa.ebird_code").includes(:ebird_taxon).where("taxa.category != ebird_taxa.category OR ebird_taxa.ebird_version != 2024")

      puts "RANK CHANGED:\n\n"

      data = taxa_rank.map {|tx| et = tx.ebird_taxon.ebird_version == 2024 ? tx.ebird_taxon : nil
                                  {taxon: tx, ebird_taxon: et, code: tx.ebird_code,
                                  old_name: tx.name_en, new_name: et&.name_en || "-----",
                                  oldcat: tx.category, newcat: et&.category || "REMOVED",
                                   species: (tx.species ? "+" : ""),
                                   loc_sp: (tx.species&.local_species&.count.to_s),
                                   obs: tx.observations.count.to_s}}
      attrs = %i[code old_name oldcat new_name newcat species loc_sp obs]
      headers = Hash[ attrs.zip(["Code", "Old name", "Old cat", "New name", "New cat", "Sp", "Loc sp", "Obs"]) ]
      pads = Hash[ attrs.map do |a|
        [a, (data.map{|d| d[a].size} + [headers[a].size]).max]
      end ]

      length = pads.values.sum + ((attrs.size - 1) * 3) + 4
      puts "-" * length
      head_row = headers.map{|a, h| h.rjust(pads[a])}.join(" | ")
      puts "| #{head_row} |"
      puts "-" * length
      data.each do |d|
        inner = attrs.map {|k| d[k].rjust(pads[k])}.join(" | ")
        puts "| #{inner} | "
      end
      puts "-" * length
    end

    task :fix_removed_codes => :environment do
      # Herring Gull was removed
      hergul = Taxon.find_by(ebird_code: "hergul")
      hergul.child_ids = []
      hergul.save!
      hergul.destroy!

      # # Eastern Whip-poor-will - code updated (could have just copied all data?)
      # # But here species exists! So we just copy over the code and everything.
      # old_whip = Taxon.find_by(ebird_code: "whip-p1")
      # new_whip = EBirdTaxon.find_by(ebird_code: "easwpw1")
      # old_whip.update!(
      #   ebird_code: "easwpw1",
      #   ebird_taxon: new_whip
      # )
      # # Other attributes will be updated later

      # # Northwestern Crow (Corvus caurinus) was lumped with American Crow and completely eliminated from ebird,
      # # even as a subspecies.
      # # Update the observations:
      # nwcrow = Taxon.find_by(ebird_code: "norcro")
      # amcrow = Taxon.find_by(ebird_code: "amecro")
      # Observation.where(taxon: nwcrow).each { |obs| obs.update!(taxon: amcrow) }
      # # Create synonym and destroy species and taxon
      # amcrow_sp = amcrow.species
      # nwcrow_sp = nwcrow.species
      # amcrow_sp.url_synonyms.create!(name_sci: "Corvus caurinus", reason: "lump")
      # nwcrow_sp.destroy!
      # nwcrow.destroy!
    end

    task clean_ebird_taxa: :environment do
      old_etaxa = EBirdTaxon.where(ebird_version: 2023)
      to_fix = Taxon.joins(:ebird_taxon).merge(old_etaxa)
      num_to_fix = to_fix.count
      puts "\n\nREPORT:"
      puts "Number of 2023 taxa left: #{old_etaxa.count}"
      puts "Number of my taxa referencing those: #{num_to_fix}\n\n"
      if num_to_fix == 0
        old_etaxa.delete_all
        puts "Old eBird taxa removed."
      else
        puts "To fix:"
        puts to_fix.map(&:name_sci).join(", ")
        puts "Fix the taxa in `fix_taxa` task"
      end
    end

  end
end

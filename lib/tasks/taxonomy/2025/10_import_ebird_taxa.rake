# frozen_string_literal: true

namespace :tax do
  namespace :update2025 do
    task import_ebird_taxa: [:import_ebird_csv, :list_rank_changes, :clean_ebird_taxa]

    task import_ebird_csv: :environment do
      filename = ENV["CSV"] || "./data/eBird_Taxonomy_v2025.csv"

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
              taxon_concept_id: taxon_concept_id.gsub!(/^avibase\-/, ""),
              ebird_order_num_str: ebird_order,
              parent_id: codes[report_as],
              ebird_version: 2025,
              index_num: idx + 1
          )
          codes[code] = e_taxon.id
        end
      end
    end



    task :list_rank_changes => :environment do
      taxa_rank = Taxon.joins("LEFT OUTER JOIN ebird_taxa ON taxa.ebird_code = ebird_taxa.ebird_code").includes(:ebird_taxon).where("taxa.category != ebird_taxa.category OR ebird_taxa.ebird_version != 2025")

      puts "RANK CHANGED:\n\n"

      data = taxa_rank.map {|tx| et = tx.ebird_taxon.ebird_version == 2025 ? tx.ebird_taxon : nil
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

    task clean_ebird_taxa: :environment do
      old_etaxa = EBirdTaxon.where(ebird_version: 2024)
      to_fix = Taxon.joins(:ebird_taxon).merge(old_etaxa)
      num_to_fix = to_fix.count
      puts "\n\nREPORT:"
      puts "Number of 2024 taxa left: #{old_etaxa.count}"
      puts "Number of my taxa referencing those: #{num_to_fix}\n\n"
      if num_to_fix == 0
        # puts old_etaxa.map(&:name_sci).join(", ")
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

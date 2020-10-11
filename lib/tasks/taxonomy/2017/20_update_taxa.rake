# frozen_string_literal: true

namespace :tax do

  namespace :update2017 do

    task :update_taxa => :environment do
      exceptions = %w(weywag6 lbbgul4 bewswa1)

      codes = {}

      Taxon.update_all(index_num: 0) # workaround

      Taxon.joins(:ebird_taxon).preload(:ebird_taxon => :parent).order("ebird_taxa.index_num").each_with_index do |taxon, idx|
        ebtx = taxon.ebird_taxon

        unless taxon.ebird_code.in?(exceptions)
          taxon.assign_attributes(
              name_sci: ebtx.name_sci,
              name_en: ebtx.name_en,
              category: ebtx.category,
              parent_id: codes[ebtx.parent&.ebird_code]
          )
        end

        taxon.update!(
            order: ebtx.order,
            family: ebtx.family
        )

        taxon.update_column(:index_num, idx + 1) # workaround
        codes[taxon.ebird_code] = taxon.id
      end

      Taxon.find_by_ebird_code("unrepbirdsp").update_column(:index_num, Taxon.count)

    end

    task :find_species_problems => :environment do
      species_rank = Species.joins(:high_level_taxa).includes(:high_level_taxa).where("taxa.category != 'species'")

      puts "RANK CHANGED:\n\n"

      species_rank.each do |sp|
        puts "#{sp.name_sci}"
        puts "               - changed to #{sp.high_level_taxon.category} (#{sp.high_level_taxon.name_sci})"
      end

      species_sci = Species.joins(:high_level_taxa).includes(:high_level_taxa).where("taxa.name_sci != species.name_sci")

      puts "\n\nSCIENTIFIC NAME CHANGED:\n\n"

      species_sci.each do |sp|
        puts "#{sp.name_sci}"
        puts "               - changed to #{sp.high_level_taxon.name_sci}"
      end

      species_name = Species.joins(:high_level_taxa).includes(:high_level_taxa).where("taxa.name_en != species.name_en")

      puts "\n\nENGLISH NAME CHANGED:\n\n"

      species_name.each do |sp|
        puts "#{sp.name_sci} (#{sp.name_en})"
        puts "               - changed to #{sp.high_level_taxon.name_sci} (#{sp.high_level_taxon.name_en})"
      end
    end

  end

end

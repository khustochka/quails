# frozen_string_literal: true

namespace :tax do
  namespace :update2021 do
    #task update_species: [:reattach_species, :update_species_name_sci, :update_species_name_en]

    task find_species_changes: :environment do
      species_rank = Species.
          joins("LEFT OUTER JOIN (SELECT * FROM taxa WHERE taxa.category = 'species') as taxa2 on taxa2.species_id = species.id").
          where("taxa2.id IS NULL")

      puts "RANK CHANGED:\n\n"

      species_rank.each do |sp|
        puts "- " +  sp.name_sci
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

    task update_species: :environment do
      spcs = Species.includes(:high_level_taxa, :taxa)

      spcs.each do |sp|
        synonym_type = nil
        # Special case - code was left for the Grass Wren, so we have to manually move over the species
        if sp.name_en == "Sedge Wren"
          ebtx = EBirdTaxon.find_by_ebird_code("sedwre1")
          tx = ebtx.promote(species: sp)
          EBirdTaxon.find_by_ebird_code("sedwre").taxon.observations.each {|obs| obs.update(taxon: tx)}
          sp.high_level_taxa.reload
          synonym_type = "split"
          puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
        end
        if sp.high_level_taxa.empty?
          # Rank has changed
          ranks = sp.taxa.map(&:category).uniq
          if ranks.include?("slash")
            case sp.name_sci
            when "Sylvia cantillans"
              ebtx = EBirdTaxon.find_by_ebird_code("easwar1")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              # Nominative species remains the same
              puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            when "Alaudala rufescens"
              ebtx = EBirdTaxon.find_by_ebird_code("tstlar1")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              synonym_type = "split"
              puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            when "Oenanthe hispanica"
              ebtx = EBirdTaxon.find_by_ebird_code("bkewhe2")
              tx = ebtx.promote(species: sp)
              EBirdTaxon.find_by_ebird_code("blewhe1").taxon.observations.each {|obs| obs.update(taxon: tx)}
              sp.high_level_taxa.reload
              synonym_type = "split"
              puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            else
              puts "*** Species #{sp.name_sci} seems to be split."
              next
            end
          elsif ranks.include?("issf")
            case sp.name_sci
            when "Caracara cheriway"
              ebtx = EBirdTaxon.find_by_ebird_code("y00678")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              synonym_type = "lump"
              puts "*** #{sp.name_sci} lumped into #{sp.high_level_taxon.name_sci}."
            else
              puts "*** Species #{sp.name_sci} seems to be lumped."
              next
            end
          else
            raise "Something wrong with the rank of species: #{sp.name_sci}"
          end
        end

        if sp.name_sci != sp.high_level_taxon.name_sci
          sp.assign_attributes(authority: nil, needs_review: true)
        end
        sp.name_sci = sp.high_level_taxon.name_sci
        # Do not perform change like: Common Wood Pigeon to Common Wood-Pigeon
        unless sp.name_en_overwritten || sp.high_level_taxon.name_en.sub(/\A(.*) ([^ ]+)\Z/, '\1-\2') == sp.name_en
          sp.assign_attributes(name_en: sp.high_level_taxon.name_en)
        end
        sp.save!

        if sp.name_sci_previously_changed?
          old_name = sp.name_sci_previously_was

          # Are there any synonyms with the new name (e.g. Tetrastes bonasia)?
          UrlSynonym.where(name_sci: sp.name_sci).yield_self do |reverse_synonym|
            reverse_synonym.destroy_all if reverse_synonym.any?
          end

          UrlSynonym.create(name_sci: old_name, species: sp, reason: synonym_type)
          puts "#{old_name} renamed to #{sp.name_sci}"
        end

      end
    end

  end
end

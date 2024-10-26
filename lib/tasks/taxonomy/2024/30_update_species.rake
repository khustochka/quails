# frozen_string_literal: true

namespace :tax do
  namespace :update2024 do
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
        unless sp.name_en_overwritten || sp.high_level_taxon.name_en.sub(/\A(.*)([^ ]+)-([^ ]+)\Z/, '\1\2 \3') == sp.name_en
          puts "#{sp.name_sci} (#{sp.name_en})"
          puts "               - changed to #{sp.high_level_taxon.name_sci} (#{sp.high_level_taxon.name_en})"
        end
      end
    end

    task update_species: :environment do
      # Special case: Tyto furcata inherited the `norgos` code
      EBirdTaxon.find_by_ebird_code("webowl1").promote
      eu_barnowl = Taxon.find_by_ebird_code("webowl1")
      eu_sp = Species.find_by_name_sci("Tyto alba")
      eu_barnowl.lift_to_species(species: eu_sp)

      am_barnowl = Taxon.find_by_ebird_code("brnowl")
      am_sp = am_barnowl.lift_to_species

      SpeciesSplit.create!(superspecies: eu_barnowl.species, subspecies: am_barnowl.species)

      LocalSpecies.where(locus: Locus.find_by_slug("manitoba"), species: eu_sp).update!(species: am_sp)

      # Larus argentatus

      am_gull = Taxon.find_by_ebird_code("amhgul1")
      am_gull.species_id = nil
      am_gull.save!
      am_gull.lift_to_species
      euro_gull = EBirdTaxon.find_by_ebird_code("euhgul1").promote

      SpeciesSplit.create!(superspecies: euro_gull.species, subspecies: am_gull.species)
      LocalSpecies.where(locus: Locus.find_by_slug("manitoba"), species: euro_gull.species).update!(species: am_gull.species)

      spcs = Species.includes(:high_level_taxa, :taxa)
      spcs.each do |sp|
        synonym_type = nil
        if sp.high_level_taxa.empty?
          # Rank has changed
          ranks = sp.taxa.map(&:category).uniq
          if ranks.include?("slash")
            case sp.name_sci
            when "***"
              # ebtx = EBirdTaxon.find_by_ebird_code("rinphe1")
              # ebtx.promote(species: sp)
              # sp.high_level_taxa.reload
              # # Nominative species remains the same
              # puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            when "Calonectris diomedea"
              ebtx = EBirdTaxon.find_by_ebird_code("scoshe1")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              sp.assign_attributes(needs_review: true)
              # Nominative species remains the same
              # puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            when "Tarsiger cyanurus"
              ebtx = EBirdTaxon.find_by_ebird_code("refblu1")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              sp.assign_attributes(needs_review: true)
              # Nominative species remains the same
              # puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            when "Cecropis daurica"
              ebtx = EBirdTaxon.find_by_ebird_code("rerswa8")
              ebtx.promote(species: sp)
              sp.high_level_taxa.reload
              synonym_type = "split"
              puts "*** #{sp.name_sci} split into #{sp.high_level_taxon.name_sci}."
            else
              puts "*** Species #{sp.name_sci} seems to be split."
              next
            end
          elsif ranks.include?("issf") || ranks.include?("form")
            case sp.name_sci
            when "***"
              # ebtx = EBirdTaxon.find_by_ebird_code("crelar1")
              # ebtx.promote(species: sp)
              # sp.high_level_taxa.reload
              # puts "*** #{sp.name_sci} lumped into #{sp.high_level_taxon.name_sci}."
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
        unless sp.name_en_overwritten || sp.high_level_taxon.name_en.sub(/\A(.*)([^ ]+)-([^ ]+)\Z/, '\1\2 \3') == sp.name_en
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

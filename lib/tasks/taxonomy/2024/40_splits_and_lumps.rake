# frozen_string_literal: true

namespace :tax do
  namespace :update2024 do
    task fix_splits_and_lumps: [:fix_lumps, :implement_splits, :validate_species, :update_order_family_sorting, :fix_observations]

    task fix_lumps: :environment do
      # Acanthis hornemanni was lumped into Acanthis flammea

      sp_hoary = Species.find_by_name_sci("Acanthis hornemanni")
      sp_common = Species.find_by_name_sci("Acanthis flammea")

      # Promote Acanthis flammea ebird taxon to taxon-species. This will link the taxon-species to an existing
      # Acanthis flammea species, and all its taxa-children (including hoary and common subsp)

      eb_redpoll = EBirdTaxon.find_by_name_sci("Acanthis flammea")
      eb_redpoll.promote

      # Remove Acanthis hornemanni from local_species
      sp_hoary.local_species.each do |loc_sp|
        locus = loc_sp.locus
        loc_sp.destroy!
        # Create entry for glaucoides at the same locus if not exists
        # glac = LocalSpecies.find_or_create_by!(species: larus_glaucoides, locus: locus)
      end

      # 3. Destroy Acanthis hornemanni
      sp_hoary.send(:destroy_associations) # Just to check for exceptions
      # Properly update index number before destroying
      sp_hoary.remove_from_list
      sp_hoary.delete

      # 4. Create url synonym
      sp_common.url_synonyms.create!(name_sci: "Acanthis hornemanni", reason: "lump")
      sp_common.update!(needs_review: true)
    end

    task implement_splits: :environment do

    end

    task validate_species: :environment do
      # Check that all species match taxa-species

      species_rank = Species.
          joins("LEFT OUTER JOIN (SELECT * FROM taxa WHERE taxa.category = 'species') as taxa2 on taxa2.species_id = species.id").
          where("taxa2.id IS NULL")

      if species_rank.count > 0
        puts "Species with invalid rank:"
        puts species_rank.map(&:name_sci).join(", ")
      else
        puts "All species valid."
      end
    end

    task update_order_family_sorting: :environment do
      Species.acts_as_list_no_update do
        Species.joins(:high_level_taxa).preload(:high_level_taxa).order("taxa.index_num").each_with_index do |species, idx|
          tx = species.high_level_taxon

          species.update!(
              order: tx.order,
              family: tx.family.match(/^\w+dae/)[0],
              index_num: idx + 1
          )
        end
      end

      order_valid =
          Species.count("DISTINCT index_num") == Species.all.count &&
              Species.maximum(:index_num) == Species.all.count

      if order_valid
        puts "\nSpecies ordering validated."
      else
        raise "Species ordering invalid!"
      end
    end

    task fix_observations: :environment do
      # aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      # slash_pheasant = Taxon.find_by_ebird_code("rinphe")
      # new_pheasant = Taxon.find_by_ebird_code("rinphe1")
      #
      # slash_pheasant.observations.each do |obs|
      #   obs.update!(taxon_id: new_pheasant.id)
      # end
    end
  end
end

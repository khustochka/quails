# frozen_string_literal: true

namespace :tax do
  namespace :update2018 do
    task fix_splits_and_lumps: [:fix_lumps, :implement_splits, :update_order_family_sorting, :fix_observations]

    task fix_lumps: :environment do
      # # Larus thayeri was lumped into Larus glaucoides
      #
      # larus_thayeri = Species.find_by_name_sci("Larus thayeri")
      # larus_glaucoides = Species.find_by_name_sci("Larus glaucoides")
      #
      # # Promote Larus glaucoides ebird taxon to taxon-species. This will link the taxon-species to an existing
      # # lar. gl. species, and all its taxa-children (including thayeri subsp)
      #
      # eb_larus_glaucoides = EBirdTaxon.find_by_name_sci("Larus glaucoides")
      # eb_larus_glaucoides.promote
      #
      # # Remove Larus thayeri from local_species
      # larus_thayeri.local_species.each do |loc_sp|
      #   locus = loc_sp.locus
      #   loc_sp.destroy!
      #   # Create entry for glaucoides at the same locus if not exists
      #   glac = LocalSpecies.find_or_create_by!(species: larus_glaucoides, locus: locus)
      # end
      #
      # # 3. Destroy Larus thayeri
      # larus_thayeri.send(:destroy_associations) # Just to check for exceptions
      # # Properly update index number before destroying
      # larus_thayeri.send(:reorder_positions, :index_num, larus_thayeri.index_num_was, false, {})
      # larus_thayeri.delete
      #
      # # 4. Create url synonym
      # larus_glaucoides.url_synonyms.create!(name_sci: "Larus thayeri", reason: "lump")
    end

    task implement_splits: :environment do
      # VIREO OLIVACEUS split

      # Find new subspecies and promote

      vireo_olivaceus = EBirdTaxon.find_by_ebird_code("reevir1").promote

      # MALLARD

      #mallard = EBirdTaxon.find_by_ebird_code("mallar3").promote
      # Because former subspecies and now species-taxon already exists, promoting it will not unlink
      # species from former species-now slash. That is why we need to do this separately:
      Taxon.find_by_ebird_code("mallar3").lift_to_species

      # VELVET/WHITE-WINGED SCOTER split

      velvet_scoter = EBirdTaxon.find_by_ebird_code("whwsco3").promote
      whitewinged_scoter = EBirdTaxon.find_by_ebird_code("whwsco4").promote

      # Update local species

      aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      whitewinged_scoter.species.local_species.where(locus_id: aba_locs).each do |loc_sp|
        loc_sp.update(species: velvet_scoter.species)
      end

      SpeciesSplit.create!(superspecies: velvet_scoter.species, subspecies: whitewinged_scoter.species)

      # Check that all species match taxa-species

      species_rank = Species.
          joins("LEFT OUTER JOIN (SELECT * FROM taxa WHERE taxa.category = 'species') as taxa2 on taxa2.species_id = species.id").
          where("taxa2.id IS NULL")

      if species_rank.count > 0
        puts "Species with invalid rank:"
        puts species_rank.map(&:name_sci).join(", ")
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
        puts "\nTaxa ordering validated."
      else
        raise "Taxa ordering invalid!"
      end
    end

    task fix_observations: :environment do
      # aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      # Basic promotions

      {
          "reevir" => "reevir1",
          "whwsco" => "whwsco3"
      }.each do |old, new|
        old_taxon = Taxon.find_by_ebird_code(old)
        new_taxon = Taxon.find_by_ebird_code(new)

        observations = old_taxon.observations.joins(:card)

        observations.each do |obs|
          obs.update(taxon: new_taxon)
        end
      end

      # Leave MALLARD slash in TX and AZ

      tx_az_locs = aba_locs = %w(texas arizona).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      old_mallard = Taxon.find_by_ebird_code("mallar")
      new_mallard = Taxon.find_by_ebird_code("mallar3")

      not_tx_az_observations = old_mallard.observations.joins(:card).where.not(cards: {locus_id: tx_az_locs})
      not_tx_az_observations.each do |obs|
        obs.update(taxon: new_mallard)
      end
    end
  end
end

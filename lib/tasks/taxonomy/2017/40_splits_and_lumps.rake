# frozen_string_literal: true

namespace :tax do
  namespace :update2017 do
    task fix_splits_and_lumps: [:fix_larus_thayeri_lump, :implement_splits, :update_order_family_sorting, :fix_observations]

    task fix_larus_thayeri_lump: :environment do
      # Larus thayeri was lumped into Larus glaucoides

      larus_thayeri = Species.find_by_name_sci("Larus thayeri")
      larus_glaucoides = Species.find_by_name_sci("Larus glaucoides")

      # Promote Larus glaucoides ebird taxon to taxon-species. This will link the taxon-species to an existing
      # lar. gl. species, and all its taxa-children (including thayeri subsp)

      eb_larus_glaucoides = EbirdTaxon.find_by_name_sci("Larus glaucoides")
      eb_larus_glaucoides.promote

      # Remove Larus thayeri from local_species
      larus_thayeri.local_species.each do |loc_sp|
        locus = loc_sp.locus
        loc_sp.destroy!
        # Create entry for glaucoides at the same locus if not exists
        glac = LocalSpecies.find_or_create_by!(species: larus_glaucoides, locus: locus)
      end

      # 3. Destroy Larus thayeri
      larus_thayeri.send(:destroy_associations) # Just to check for exceptions
      # Properly update index number before destroying
      larus_thayeri.send(:reorder_positions, :index_num, larus_thayeri.index_num_was, false, {})
      larus_thayeri.delete

      # 4. Create url synonym
      larus_glaucoides.url_synonyms.create!(name_sci: "Larus thayeri", reason: "lump")
    end

    task implement_splits: :environment do
      # HEN/NORTHERN HARRIER split

      hen_harrier = EbirdTaxon.find_by_ebird_code("norhar1").promote
      nor_harrier = EbirdTaxon.find_by_ebird_code("norhar2").promote

      # GREAT GREY/NORTHERN SHRIKE split

      gg_shrike = EbirdTaxon.find_by_ebird_code("norshr1").promote
      nor_shrike = EbirdTaxon.find_by_ebird_code("norshr4").promote

      # Update local species

      aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      hen_harrier.species.local_species.where(locus_id: aba_locs).each do |loc_sp|
        loc_sp.update(species: nor_harrier.species)
      end

      gg_shrike.species.local_species.where(locus_id: aba_locs).each do |loc_sp|
        loc_sp.update(species: nor_shrike.species)
      end

      SpeciesSplit.create!(superspecies: hen_harrier.species, subspecies: nor_harrier.species)
      SpeciesSplit.create!(superspecies: gg_shrike.species, subspecies: nor_shrike.species)
    end

    task update_order_family_sorting: :environment do
      Species.update_all(index_num: 0) # workaround

      Species.joins(:high_level_taxa).preload(:high_level_taxa).order("taxa.index_num").each_with_index do |species, idx|
        tx = species.high_level_taxon

        species.update!(
            order: tx.order,
            family: tx.family.match(/^\w+dae/)[0]
        )

        species.update_column(:index_num, idx + 1) # workaround
      end
    end

    task fix_observations: :environment do
      aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      # HEN/NORTHERN HARRIER split

      old_harrier = Taxon.find_by_ebird_code("norhar")
      hen_harrier = Taxon.find_by_ebird_code("norhar1")
      nor_harrier = Taxon.find_by_ebird_code("norhar2")

      aba_observations = old_harrier.observations.joins(:card).where(cards: {locus_id: aba_locs})
      euro_observations = old_harrier.observations.joins(:card).where("cards.locus_id NOT IN (?)", aba_locs)

      aba_observations.each do |obs|
        obs.update(taxon: nor_harrier)
      end
      euro_observations.each do |obs|
        obs.update(taxon: hen_harrier)
      end

      # GREAT GREY/NORTHERN SHRIKE split

      old_shrike = Taxon.find_by_ebird_code("norshr")
      gg_shrike = Taxon.find_by_ebird_code("norshr1")
      nor_shrike = Taxon.find_by_ebird_code("norshr4")

      aba_observations = old_shrike.observations.joins(:card).where(cards: {locus_id: aba_locs})
      euro_observations = old_shrike.observations.joins(:card).where("cards.locus_id NOT IN (?)", aba_locs)

      aba_observations.each do |obs|
        obs.update(taxon: nor_shrike)
      end
      euro_observations.each do |obs|
        obs.update(taxon: gg_shrike)
      end
    end
  end
end

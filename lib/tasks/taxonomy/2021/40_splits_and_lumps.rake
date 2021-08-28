# frozen_string_literal: true

namespace :tax do
  namespace :update2021 do
    task fix_splits_and_lumps: [:fix_lumps, :implement_splits, :validate_species, :update_order_family_sorting, :fix_observations]

    task fix_lumps: :environment do

    end

    task implement_splits: :environment do
      aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

      short_billed_gull = EbirdTaxon.find_by_ebird_code("mewgul2").promote
      common_gull = Taxon.find_by_ebird_code("mewgul")

      common_gull.observations.joins(:card).where(cards: { locus_id: aba_locs }).each {|obs| obs.update(taxon: short_billed_gull)}

      SpeciesSplit.create!(superspecies: common_gull.species, subspecies: short_billed_gull.species)

      # VELVET/WHITE-WINGED SCOTER split

      # velvet_scoter = EbirdTaxon.find_by_ebird_code("whwsco3").promote
      # whitewinged_scoter = EbirdTaxon.find_by_ebird_code("whwsco4").promote
      #
      # # Update local species
      #
      # aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)
      #
      # whitewinged_scoter.species.local_species.where(locus_id: aba_locs).each do |loc_sp|
      #   loc_sp.update(species: velvet_scoter.species)
      # end

      # SpeciesSplit.create!(superspecies: velvet_scoter.species, subspecies: whitewinged_scoter.species)
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


    end
  end
end

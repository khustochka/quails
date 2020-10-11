# frozen_string_literal: true

namespace :tax do

  desc "Map all observations from legacy species to new taxa"
  task :map_observations => :environment do

    base = Observation.where(taxon_id: nil).joins(:card)

    # Specific subtaxa
    old_colliv = LegacySpecies.find_by_code "colliv"
    feral_colliv = Taxon.find_by_name_sci("Columba livia (Feral Pigeon)")
    base.where(legacy_species_id: old_colliv.id).update_all(taxon_id: feral_colliv.id)

    uk_locs = Locus.find_by_slug("united_kingdom").subregion_ids
    old_larfus = LegacySpecies.find_by_code "larfus"
    larfus_grael = Taxon.find_by_name_sci("Larus fuscus graellsii")
    base.where(legacy_species_id: old_larfus.id, "cards.locus_id" => uk_locs).update_all(taxon_id: larfus_grael.id)

    aba_locs = %w(usa canada).map {|slug| Locus.find_by_slug(slug).subregion_ids}.inject(:+)

    old_hirrus = LegacySpecies.find_by_code "hirrus"
    hirrus_amer = Taxon.find_by_name_sci("Hirundo rustica erythrogaster")
    base.where(legacy_species_id: old_hirrus.id, "cards.locus_id" => aba_locs).update_all(taxon_id: hirrus_amer.id)

    old_anacre = LegacySpecies.find_by_code "anacre"
    anacre_amer = Taxon.find_by_name_sci("Anas crecca carolinensis")
    anacre_euro = Taxon.find_by_name_sci("Anas crecca crecca/nimia")
    base.where(legacy_species_id: old_anacre.id, "cards.locus_id" => aba_locs).update_all(taxon_id: anacre_amer.id)    
    base.where(legacy_species_id: old_anacre.id).where("cards.locus_id NOT IN (?)", aba_locs).update_all(taxon_id: anacre_euro.id)

    old_lararg = LegacySpecies.find_by_code "lararg"
    lararg_amer = Taxon.find_by_name_sci("Larus argentatus smithsonianus")
    base.where(legacy_species_id: old_lararg.id, "cards.locus_id" => aba_locs).update_all(taxon_id: lararg_amer.id)

    # Process the rest

    legacy_sps = LegacySpecies.where(id: base.select(:legacy_species_id))
    legacy_sps.each do |lsp|
      sp = lsp.species
      if sp
        base.where(legacy_species_id: lsp.id).update_all(taxon_id: sp.taxa.where(category: "species").first.id)
      else
        puts "Species mapping not present for #{lsp.name_sci}. Please set the mapping, backup it with rake tax:backup_mapping and rerun."
        abort
      end
    end

    # Aves sp

    base.where(legacy_species_id: 0).update_all(taxon_id: Taxon.find_by_ebird_code("bird1"))

    # Check if there are observations without taxon:
    obs = Observation.where(taxon_id: nil)
    if obs.any?
      raise "There are still #{obs.size} observations not mapped to taxa!"
    end

  end


end

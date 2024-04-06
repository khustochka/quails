# frozen_string_literal: true

namespace :tax do
  # desc "Backup mapping of legacy species to species to the YAML file"
  task backup_mapping: :environment do
    res = LegacySpecies.where("species_id IS NOT NULL").order("legacy_species.id").includes(:species).pluck("legacy_species.id, species.name_sci")

    File.open("./data/sp_map.yml", "w") do |file|
      file.write(Hash[res].to_yaml)
    end
  end
end

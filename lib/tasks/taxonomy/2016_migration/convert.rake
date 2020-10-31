# frozen_string_literal: true

namespace :tax do
  desc "Convert an old taxonomy DB into new taxonomy"
  task convert: [
      "db:drop",
      "db:create",
      "db:restore",
      "db:migrate",
      "tax:import_ebird_taxa",
      "tax:create_species",
      "tax:restore_mapping",
      "tax:import_species_names",
      "tax:map_observations",
      "tax:map_species_images",
      "tax:remap_local_species"
  ]

  desc "Convert an old taxonomy DB into new taxonomy production"
  task convert_production: [
      "tax:import_ebird_taxa",
      "tax:create_species",
      "tax:restore_mapping",
      "tax:import_species_names",
      "tax:map_observations",
      "tax:map_species_images",
      "tax:remap_local_species"
  ]
end

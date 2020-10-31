# frozen_string_literal: true

namespace :tax do
  desc "Remap local species"
  task remap_local_species: :environment do
    LocalSpecies.all.each do |ls|
      lsp = LegacySpecies.find(ls.species_id)
      ls.update_attribute(:species_id, lsp.species_id)
    end
  end
end

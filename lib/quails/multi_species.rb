# frozen_string_literal: true

module Quails
  class MultiSpecies
    def self.fix_all
      ids = Media.really_multiple_species_ids
      Media.transaction do
        Media.where(id: ids).update_all(multi_species: true)
        Media.where.not(id: ids).update_all(multi_species: false)
      end
    end
  end
end

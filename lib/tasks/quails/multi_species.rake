# frozen_string_literal: true

namespace :quails do
  namespace :multi_species do
    desc "Mark multi species media as such"
    task refresh: :environment do
      require "quails/multi_species"

      Quails::MultiSpecies.fix_all
    end
  end
end

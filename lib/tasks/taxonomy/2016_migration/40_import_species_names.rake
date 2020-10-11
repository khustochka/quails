# frozen_string_literal: true

namespace :tax do

  desc "Move legacy species names/codes to the new species"
  task :import_species_names => :environment do

    LegacySpecies.where("species_id IS NOT NULL").preload(:species).each do |sp|
      attrs = sp.attributes.slice("name_ru", "name_uk", "name_fr", "code").merge({legacy_code: sp[:code]})
      if sp.name_sci == sp.species.name_sci
        attrs.merge!(authority: sp.authority)
      end
      sp.species.update(attrs)
    end

  end

end

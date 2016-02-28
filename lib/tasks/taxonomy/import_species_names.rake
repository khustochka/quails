namespace :tax do

  desc "Move legacy species names/codes to the new species"
  task :import_species_names => :environment do

    LegacySpecies.where("species_id IS NOT NULL").preload(:species).each do |sp|
      sp.species.update_attributes(
          sp.attributes.slice("name_ru", "name_uk", "name_fr", "code").merge({legacy_code: sp[:code]})
      )
    end

  end

end

namespace :tax do

  desc "Restore mapping of legacy species to species saved in the YAML file"
  task :restore_mapping => :environment do

    mapping = YAML::load_file("sp_map.yml")
    ids = mapping.keys
    LegacySpecies.where(id: ids).each do |sp|
      sp.update_attribute(:species_id, Species.find_by_name_sci(mapping[sp.id]).id)
    end

  end

end

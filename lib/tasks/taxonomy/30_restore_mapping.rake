namespace :tax do

  desc "Restore mapping of legacy species to species saved in the YAML file"
  task :restore_mapping => :environment do

    mapping = YAML::load_file("sp_map.yml")
    ids = mapping.keys
    errors = []
    LegacySpecies.where(id: ids).each do |sp|
      map_sp = Species.find_by_name_sci(mapping[sp.id])
      if map_sp
      	sp.update_attribute(:species_id, map_sp.id)
      else
        errors << "Invalid mapping for #{sp.name_sci}."
      end
    end
    if errors.any?
      puts errors.join("\n")
      raise "Please correct and remap with rake tax:backup_mapping."
    end
  end

end

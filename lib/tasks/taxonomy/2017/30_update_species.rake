namespace :tax do

  namespace :update2017 do

    task :update_species => [:update_species_name_sci, :update_species_name_en]

    task :update_species_name_sci => :environment do
      changed = Species.joins(:high_level_taxa).includes(:high_level_taxa).where("taxa.name_sci != species.name_sci")

      puts "\nRENAMED:\n\n"

      changed.each do |sp|
        old_name = sp.name_sci
        new_name = sp.high_level_taxon.name_sci
        # Are there any synonyms with the new name (e.g. Tetrastes bonasia)?
        reverse_synonym = UrlSynonym.where(name_sci: new_name)
        if reverse_synonym
          reverse_synonym.destroy_all
        end
        sp.update!(name_sci: new_name)
        # Create new synonym
        UrlSynonym.create(name_sci: old_name, species: sp)
        puts "#{old_name} renamed to #{new_name}"
      end

    end

    task :update_species_name_en => :environment do
      changed = Species.joins(:high_level_taxa).includes(:high_level_taxa).where("taxa.name_en != species.name_en")

      changed.each do |sp|
        old_name = sp.name_en
        new_name = sp.high_level_taxon.name_en

        # Do not perform change like: Common Wood Pigeon to Common Wood-Pigeon
        if old_name.sub(/\A(.*) ([^ ]+)\Z/, '\1-\2') == new_name || old_name == "Rough-legged Buzzard"
          puts "            -- No change #{old_name} to #{new_name}"
        else
          sp.update!(name_en: new_name)
          puts "#{old_name} renamed to #{new_name}"
        end
      end

    end

  end

end

# frozen_string_literal: true

namespace :tax do

  desc "Map all species images from legacy species to new species"
  task :map_species_images => :environment do
    sp_images = SpeciesImage.pluck(:species_id, :image_id)
    SpeciesImage.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!("species_images")
    sp_images.each do |sp_id, img_id|
      sp = LegacySpecies.find(sp_id).species
      sp.image = Image.find(img_id)
      sp.save!
    end
  end

end

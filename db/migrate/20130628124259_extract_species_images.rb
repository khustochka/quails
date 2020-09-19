class ExtractSpeciesImages < ActiveRecord::Migration[4.2]
  class Species < ActiveRecord::Base
    has_one :species_image
    has_one :image, through: :species_image
  end

  class SpeciesImage < ActiveRecord::Base
    belongs_to :species
    belongs_to :image
  end

  def up
    create_table :species_images do |t|
      t.integer :species_id, null: false
      t.integer :image_id, null: false
    end

    add_index "species_images", ["species_id"], :name => "index_species_images_on_species_id", :unique => true

    Species.all.each do |sp|
      if sp.image_id
        sp.image = Image.find(sp.image_id)
      end
    end

    remove_column :species, :image_id
  end

  def down
    drop_table :species_images
    add_column :species, "image_id", :integer
  end
end

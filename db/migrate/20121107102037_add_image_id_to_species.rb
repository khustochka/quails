class AddImageIdToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :image_id, :integer
  end
end

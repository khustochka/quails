class AddImageIdToSpecies < ActiveRecord::Migration[4.2]
  def change
    add_column :species, :image_id, :integer
  end
end

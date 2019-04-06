class AddFrenchNameToSpecies < ActiveRecord::Migration[4.2]
  def change
    add_column :species, :name_fr, :string, limit: 255
  end
end

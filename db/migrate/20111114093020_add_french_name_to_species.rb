class AddFrenchNameToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :name_fr, :string
  end
end

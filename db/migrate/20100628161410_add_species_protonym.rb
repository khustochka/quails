class AddSpeciesProtonym < ActiveRecord::Migration[4.2]
  def self.up
    add_column :species, :protonym, :string, limit: 255
  end

  def self.down
    remove_column :species, :protonym
  end
end

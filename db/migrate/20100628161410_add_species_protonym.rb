class AddSpeciesProtonym < ActiveRecord::Migration
  def self.up
    add_column :species, :protonym, :string
  end

  def self.down
    remove_column :species, :protonym
  end
end

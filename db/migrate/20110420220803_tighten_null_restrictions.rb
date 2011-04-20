class TightenNullRestrictions < ActiveRecord::Migration
  def self.up
    change_column :observations, :species_id, :integer, :null => false
    change_column :observations, :locus_id, :integer, :null => false
  end

  def self.down
    change_column :observations, :species_id, :integer, :null => true
    change_column :observations, :locus_id, :integer, :null => true
  end
end

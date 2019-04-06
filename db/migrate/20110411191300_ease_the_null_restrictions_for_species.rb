class EaseTheNullRestrictionsForSpecies < ActiveRecord::Migration[4.2]
  def self.up
    change_column :species, :authority, :string, :null => true, limit: 255
    change_column :species, :name_ru, :string, :null => true, limit: 255
    change_column :species, :name_uk, :string, :null => true, limit: 255
    change_column :species, :order, :string, :null => true, limit: 255
    change_column :species, :avibase_id, :string, :limit => 16, :null => true
  end

  def self.down
    change_column :species, :authority, :string, :null => false
    change_column :species, :name_ru, :string, :null => false
    change_column :species, :name_uk, :string, :null => false
    change_column :species, :order, :string, :null => false
    change_column :species, :avibase_id, :string, :limit => 16, :null => false
  end
end

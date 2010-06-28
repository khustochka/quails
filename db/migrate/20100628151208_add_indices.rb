class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :species, :name_sci
    add_index :species, :code
    add_index :species, :index_num

    add_index :locus, :code
    add_index :locus, :parent_id
    add_index :locus, :loc_type

    add_index :observations, :species_id
    add_index :observations, :locus_id
    add_index :observations, :observ_date
    add_index :observations, :mine
  end

  def self.down
  end
end

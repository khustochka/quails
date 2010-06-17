class CreateLoci < ActiveRecord::Migration
  def self.up
    create_table :loci do |t|
      t.string :code,   :null => false
      t.integer :parent_id
      t.string :type
      t.string :name_en
      t.string :name_ru
      t.string :name_uk
      t.float :lat
      t.float :lon
    end
  end

  def self.down
    drop_table :loci
  end
end

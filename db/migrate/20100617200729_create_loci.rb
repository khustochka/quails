class CreateLoci < ActiveRecord::Migration[4.2]
  def self.up
    create_table :loci do |t|
      t.string :code,   :null => false
      t.integer :parent_id
      t.string :type,   :null => false
      t.string :name_en, limit: 255
      t.string :name_ru, limit: 255
      t.string :name_uk, limit: 255
      t.float :lat
      t.float :lon
    end
  end

  def self.down
    drop_table :loci
  end
end

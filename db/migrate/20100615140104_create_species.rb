class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.string :code,       :limit => 6
      t.string :name_sci,   :null => false
      t.string :authority,  :null => false
      t.string :name_en,    :null => false
      t.string :name_ru,    :null => false
      t.string :name_uk,    :null => false
      t.integer :index_num, :null => false
      t.string :order,      :null => false
      t.string :family,     :null => false
      t.string :avibase_id,     :null => false
    end
  end

  def self.down
    drop_table :species
  end
end

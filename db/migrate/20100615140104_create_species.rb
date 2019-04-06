class CreateSpecies < ActiveRecord::Migration[4.2]
  def self.up
    create_table :species do |t|
      t.string :code,       :limit => 6
      t.string :name_sci,   :null => false, limit: 255
      t.string :authority,  :null => false, limit: 255
      t.string :name_en,    :null => false, limit: 255
      t.string :name_ru,    :null => false, limit: 255
      t.string :name_uk,    :null => false, limit: 255
      t.integer :index_num, :null => false
      t.string :order,      :null => false, limit: 255
      t.string :family,     :null => false, limit: 255
      t.string :avibase_id,     :null => false
    end
  end

  def self.down
    drop_table :species
  end
end

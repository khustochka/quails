class IocTaxa < ActiveRecord::Migration[6.1]
  def change
    create_table :ioc_taxa do |t|
      t.string :rank, null: false
      t.boolean :extinct, default: false, null: false
      t.string :name_en
      t.string :name_sci, null: false
      t.string :authority
      t.string :breeding_range
      t.bigint :ioc_species_id

      t.integer :index_num
      t.string :version, null: false
    end
  end
end

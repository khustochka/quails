class CreateChecklists < ActiveRecord::Migration
  def change
    create_table :checklists, id: false do |t|
      t.integer :locus_id
      t.integer :species_id
      t.string :status_codes
      t.string :status_en
      t.string :status_ru
      t.string :status_uk
    end

    add_index :checklists, [:locus_id, :species_id]
  end
end

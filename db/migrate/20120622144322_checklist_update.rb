class ChecklistUpdate < ActiveRecord::Migration[4.2]
  def up
    remove_index :checklists, :name => "index_checklists_on_locus_id_and_species_id"
    add_index :checklists, :locus_id
    add_index :checklists, :species_id
    rename_column :checklists, :status_codes, :status
    rename_column :checklists, :status_en, :notes_en
    rename_column :checklists, :status_ru, :notes_ru
    rename_column :checklists, :status_uk, :notes_uk
    change_column :checklists, :locus_id, :integer, null: false
    change_column :checklists, :species_id, :integer, null: false
  end

  def down
    rename_column :checklists, :status, :status_codes
    rename_column :checklists, :notes_en, :status_en
    rename_column :checklists, :notes_ru, :status_ru
    rename_column :checklists, :notes_uk, :status_uk
    remove_index :checklists, :locus_id
    remove_index :checklists, :species_id
    add_index "checklists", ["locus_id", "species_id"], :name => "index_checklists_on_locus_id_and_species_id"
  end
end

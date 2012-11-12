class RenameChecklistToLocalSpecies < ActiveRecord::Migration

  class Checklist < ActiveRecord::Base
  end

  class LocalSpecies < ActiveRecord::Base
  end

  def up
    create_table "local_species" do |t|
      t.integer "locus_id",   :null => false
      t.integer "species_id", :null => false
      t.string  "status"
      t.string  "notes_en"
      t.string  "notes_ru"
      t.string  "notes_uk"
    end

    add_index "local_species", ["locus_id"]
    add_index "local_species", ["species_id"]

    Checklist.scoped.each do |ch|
      LocalSpecies.create!(ch.attributes)
    end

    drop_table :checklists
  end

  def down
    drop_table :local_species

    create_table "checklists", :id => false, :force => true do |t|
      t.integer "locus_id",   :null => false
      t.integer "species_id", :null => false
      t.string  "status"
      t.string  "notes_en"
      t.string  "notes_ru"
      t.string  "notes_uk"
    end

    add_index "checklists", ["locus_id"], :name => "index_checklists_on_locus_id"
    add_index "checklists", ["species_id"], :name => "index_checklists_on_species_id"

  end
end

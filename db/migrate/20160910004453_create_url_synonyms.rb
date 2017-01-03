class CreateUrlSynonyms < ActiveRecord::Migration
  def change
    create_table :url_synonyms do |t|
      t.string "name_sci"
      t.references :species
    end
  end
end

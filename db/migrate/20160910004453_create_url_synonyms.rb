class CreateUrlSynonyms < ActiveRecord::Migration[4.2]
  def change
    create_table :url_synonyms do |t|
      t.string "name_sci"
      t.references :species
    end
  end
end

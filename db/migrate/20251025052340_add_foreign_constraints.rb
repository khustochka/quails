class AddForeignConstraints < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :url_synonyms, :species, column: :species_id

    add_index(:media, :spot_id)
    add_index(:url_synonyms, :species_id)
  end
end

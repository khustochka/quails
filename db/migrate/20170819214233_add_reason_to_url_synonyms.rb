class AddReasonToUrlSynonyms < ActiveRecord::Migration[5.1]
  def change
    add_column :url_synonyms, :reason, :string
  end
end

class AddCollationForNameSci < ActiveRecord::Migration[6.1]
  def up
    change_column :species, :name_sci, :string, null: false, collation: "C"
    change_column :url_synonyms, :name_sci, :string, collation: "C"
  end

  def down

  end
end

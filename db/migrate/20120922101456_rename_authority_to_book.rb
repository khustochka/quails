class RenameAuthorityToBook < ActiveRecord::Migration[4.2]
  def up
    rename_table :authorities, :books
    rename_column :book_species, :authority_id, :book_id
  end
end

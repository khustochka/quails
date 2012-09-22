class RenameAuthorityToBook < ActiveRecord::Migration
  def up
    rename_table :authorities, :books
    rename_column :book_species, :authority_id, :book_id
  end
end

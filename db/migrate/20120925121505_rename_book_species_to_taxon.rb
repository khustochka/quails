class RenameBookSpeciesToTaxon < ActiveRecord::Migration[4.2]
  def change
    rename_table :book_species, :taxa
  end
end

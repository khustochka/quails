class RenameBookSpeciesToTaxon < ActiveRecord::Migration
  def change
    rename_table :book_species, :taxa
  end
end

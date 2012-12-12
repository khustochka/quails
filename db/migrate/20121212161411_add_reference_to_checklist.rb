class AddReferenceToChecklist < ActiveRecord::Migration
  def change
    add_column :local_species, :reference, :string
  end
end

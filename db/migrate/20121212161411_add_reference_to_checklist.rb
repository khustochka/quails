class AddReferenceToChecklist < ActiveRecord::Migration[4.2]
  def change
    add_column :local_species, :reference, :string, limit: 255
  end
end

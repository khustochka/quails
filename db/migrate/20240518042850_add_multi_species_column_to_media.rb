class AddMultiSpeciesColumnToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :multi_species, :boolean, default: false
  end
end

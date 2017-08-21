class CreateSpeciesSplitsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :species_splits, if_exists: true
    create_table :species_splits do |t|
      t.references :superspecies
      t.references :subspecies
    end
  end
end

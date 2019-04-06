class RemoveColumnsFromObservations < ActiveRecord::Migration[4.2]
  def up
    remove_column :observations, :observ_date
    remove_column :observations, :locus_id
  end

  def down
  end
end

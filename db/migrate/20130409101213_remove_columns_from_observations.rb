class RemoveColumnsFromObservations < ActiveRecord::Migration
  def up
    remove_column :observations, :observ_date
    remove_column :observations, :locus_id
  end

  def down
  end
end

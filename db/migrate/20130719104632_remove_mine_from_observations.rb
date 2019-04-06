class RemoveMineFromObservations < ActiveRecord::Migration[4.2]
  def change
    remove_column :observations, :mine
  end
end

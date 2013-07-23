class RemoveMineFromObservations < ActiveRecord::Migration
  def change
    remove_column :observations, :mine
  end
end

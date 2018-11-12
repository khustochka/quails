class RemovePlaceFromObservations < ActiveRecord::Migration[5.2]
  def change
    remove_column :observations, :place
  end
end

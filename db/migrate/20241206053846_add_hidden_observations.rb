class AddHiddenObservations < ActiveRecord::Migration[8.0]
  def change
    add_column :observations, :hidden, :boolean, null: false, default: "0"
  end
end

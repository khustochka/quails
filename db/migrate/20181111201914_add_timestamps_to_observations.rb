class AddTimestampsToObservations < ActiveRecord::Migration[5.2]
  def change
    add_column :observations, :created_at, :datetime
    add_column :observations, :updated_at, :datetime
  end
end

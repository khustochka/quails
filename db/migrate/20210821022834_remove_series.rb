class RemoveSeries < ActiveRecord::Migration[6.1]
  def change
    remove_column :media, :media_series_id
    drop_table :media_series
  end
end

class AddSeries < ActiveRecord::Migration[5.1]
  def change
    create_table :media_series do |t|
      t.timestamps
    end

    add_column :media, :media_series_id, :integer, null: true
    add_index :media, :media_series_id
    add_foreign_key "media", "media_series", on_delete: :nullify
  end
end

class CreateSettingsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :settings, id: false do |t|
      t.string :key, null: false, limit: 255
      t.string :value, null: false, limit: 255
    end
  end
end

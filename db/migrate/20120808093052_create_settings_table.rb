class CreateSettingsTable < ActiveRecord::Migration
  def change
    create_table :settings, id: false do |t|
      t.string :key, null: false
      t.string :value, null: false
    end
  end
end

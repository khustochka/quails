class AddVoiceColumnToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :voice, :boolean, default: false, null: false
    change_column :observations, :mine, :boolean, default: true, null: false
  end
end

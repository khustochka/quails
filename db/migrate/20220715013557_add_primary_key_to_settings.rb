class AddPrimaryKeyToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :id, :primary_key
  end
end

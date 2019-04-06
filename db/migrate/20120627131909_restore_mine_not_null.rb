class RestoreMineNotNull < ActiveRecord::Migration[4.2]
  def up
    change_column :observations, :mine, :boolean, null: false
  end

  def down
    change_column :observations, :mine, :boolean, null: true
  end
end

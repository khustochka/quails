class RestoreMineNotNull < ActiveRecord::Migration
  def up
    change_column :observations, :mine, :boolean, null: false
  end

  def down
    change_column :observations, :mine, :boolean, null: true
  end
end

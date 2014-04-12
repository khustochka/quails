class RemovePatchesTable < ActiveRecord::Migration
  def change
    drop_table :patches
  end
end

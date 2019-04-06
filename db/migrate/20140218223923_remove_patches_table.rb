class RemovePatchesTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :patches
  end
end

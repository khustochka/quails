class RemovePatchIdFromObservation < ActiveRecord::Migration[7.0]
  def change
    remove_column :observations, :patch_id, :integer
  end
end

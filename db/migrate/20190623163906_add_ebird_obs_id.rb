class AddEBirdObsId < ActiveRecord::Migration[5.2]
  def change
    add_column :observations, :ebird_obs_id, :string, null: true
  end
end

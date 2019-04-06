class OptimizeImgObsIndices < ActiveRecord::Migration[4.2]
  def up
    remove_index :images_observations, :name => "index_images_observations_on_image_id_and_observation_id"
    add_index :images_observations, :image_id
    add_index :images_observations, :observation_id
  end

  def down
    remove_index :images_observations, :image_id
    remove_index :images_observations, :observation_id
    add_index :images_observations, [:image_id, :observation_id]
  end
end

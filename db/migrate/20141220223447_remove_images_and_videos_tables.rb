class RemoveImagesAndVideosTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :images
    drop_table :videos
    drop_table :images_observations
    drop_table :videos_observations
  end
end

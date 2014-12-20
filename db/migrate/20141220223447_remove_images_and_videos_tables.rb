class RemoveImagesAndVideosTables < ActiveRecord::Migration
  def change
    drop_table :images
    drop_table :videos
    drop_table :images_observations
    drop_table :videos_observations
  end
end

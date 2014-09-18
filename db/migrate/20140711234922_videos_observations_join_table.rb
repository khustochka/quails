class VideosObservationsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :videos, :observations, table_name: 'videos_observations'

    add_index "videos_observations", ["video_id"], name: "index_videos_observations_on_video_id", using: :btree
    add_index "videos_observations", ["observation_id"], name: "index_videos_observations_on_observation_id", using: :btree

  end
end

class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :slug,              limit: 64,                   null: false
      t.string :title
      t.string :url,                   null: false
      t.text :description
      t.integer :spot_id

      t.timestamps
    end

    add_index "videos", ["slug"], name: "index_videos_on_slug", unique: true, using: :btree
  end
end

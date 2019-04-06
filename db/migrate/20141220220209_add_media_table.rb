class AddMediaTable < ActiveRecord::Migration[4.2]
  def change
    create_table "media", force: true do |t|
      t.string "slug", limit: 64, null: false
      t.string "media_type", limit: 5, null: false
      t.string "title"
      t.string "external_id"
      t.text "description"
      t.integer "spot_id"
      t.integer  "index_num",                    default: 1000
      t.boolean  "has_old_thumbnail",            default: false
      t.text     "assets_cache",                 default: ""
      t.string   "status",            limit: 5,  default: "DEFLT"
      t.integer  "parent_id"

      t.timestamps
    end

    add_index "media", ["slug"], unique: true

    create_table "media_observations", id: false, force: true do |t|
      t.integer "media_id",       null: false
      t.integer "observation_id", null: false
    end

    add_index "media_observations", ["media_id"]
    add_index "media_observations", ["observation_id"]
  end
end

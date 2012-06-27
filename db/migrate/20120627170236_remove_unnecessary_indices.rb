class RemoveUnnecessaryIndices < ActiveRecord::Migration
  def up
    remove_index "posts", :name => "index_posts_on_status"
    remove_index "posts", :name => "index_posts_on_topic"
    remove_index "observations", :name => "index_observations_on_mine"
    remove_index "loci", :name => "index_loci_on_loc_type"
  end

  def down
    add_index "posts", ["status"], :name => "index_posts_on_status"
    add_index "posts", ["topic"], :name => "index_posts_on_topic"
    add_index "observations", ["mine"], :name => "index_observations_on_mine"
    add_index "loci", ["loc_type"], :name => "index_loci_on_loc_type"
  end
end

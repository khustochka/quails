class IntroduceUniqueIndices < ActiveRecord::Migration
  def up
    # remove existing
    remove_index "images", :name => "index_images_on_slug"
    remove_index "loci", :name => "index_loci_on_slug"
    remove_index "posts", :name => "index_posts_on_slug"
    remove_index "species", :name => "index_species_on_code"
    remove_index "species", :name => "index_species_on_name_sci"

    # add unique existing
    add_index "images", ["slug"], :name => "index_images_on_slug", :unique => true
    add_index "loci", ["slug"], :name => "index_loci_on_slug", :unique => true
    add_index "posts", ["slug"], :name => "index_posts_on_slug", :unique => true
    add_index "species", ["code"], :name => "index_species_on_code", :unique => true
    add_index "species", ["name_sci"], :name => "index_species_on_name_sci", :unique => true

    # just add
    add_index "spots", [:observation_id]
  end

  def down
  end
end

class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :code, :limit => 64, :null => false
      t.string :title
      t.text :description
      t.integer :index_num
    end

    create_table :images_observations, :id => false do |t|
      t.references :image, :null => false
      t.references :observation, :null => false
    end

    add_index(:images_observations, [:image_id, :observation_id], :unique => true)
  end

  def self.down
    drop_table :images
    drop_table :images_observations
  end
end

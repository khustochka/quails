class AddCreatedAtForImages < ActiveRecord::Migration
  def self.up
    add_column :images, :created_at, :timestamp
    add_index :images, :code
    add_index :images, :index_num
  end

  def self.down
    remove_column :images, :created_at, :timestamp
  end
end

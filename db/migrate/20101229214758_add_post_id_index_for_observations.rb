class AddPostIdIndexForObservations < ActiveRecord::Migration
  def self.up
    add_index :observations, :post_id
  end

  def self.down
  end
end

class AddPostIdIndexForObservations < ActiveRecord::Migration[4.2]
  def self.up
    add_index :observations, :post_id
  end

  def self.down
  end
end

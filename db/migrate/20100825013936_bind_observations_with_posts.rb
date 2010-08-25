class BindObservationsWithPosts < ActiveRecord::Migration
  def self.up
    add_column :observations, :post_id, :integer
  end

  def self.down
    remove_column :observations, :post_id
  end
end

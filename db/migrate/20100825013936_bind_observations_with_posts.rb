class BindObservationsWithPosts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :observations, :post_id, :integer
  end

  def self.down
    remove_column :observations, :post_id
  end
end

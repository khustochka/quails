class AddCommentedTimeToPost < ActiveRecord::Migration
  def change
    add_column :posts, :commented_at, :timestamp
  end
end

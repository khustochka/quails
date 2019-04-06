class AddCommentedTimeToPost < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :commented_at, :timestamp
  end
end

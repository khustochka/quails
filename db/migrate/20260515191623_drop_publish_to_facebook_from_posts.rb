class DropPublishToFacebookFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :publish_to_facebook, :boolean, default: false, null: false
  end
end

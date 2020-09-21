class RemoveOldLJColumns < ActiveRecord::Migration[4.2]
  def change
    remove_column :posts, :lj_post_id
    remove_column :posts, :lj_url_id
  end
end

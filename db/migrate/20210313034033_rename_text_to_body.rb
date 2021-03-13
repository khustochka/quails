class RenameTextToBody < ActiveRecord::Migration[6.1]
  def change
    rename_column :posts, :text, :body
    rename_column :comments, :text, :body
  end
end

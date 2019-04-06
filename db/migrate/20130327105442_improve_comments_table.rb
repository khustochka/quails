class ImproveCommentsTable < ActiveRecord::Migration[4.2]
  def up
    change_column :comments, :post_id, :integer, null: false
    change_column :comments, :parent_id, :integer, null: false
    change_column :comments, :name, :string, null: false, limit: 255
    change_column :comments, :text, :text, null: false
    change_column :comments, :approved, :boolean, null: false
    change_column :comments, :created_at, :timestamp, null: false
    add_column :comments, :updated_at, :timestamp

    Comment.update_all("updated_at = created_at")
    change_column :comments, :updated_at, :timestamp, null: false

  end

  def down
  end
end

class CorrectCommentHierarchy < ActiveRecord::Migration[5.1]
  def change
    change_column :comments, :parent_id, :integer, null: true
    ActiveRecord::Base.connection.execute("UPDATE comments SET parent_id = NULL WHERE parent_id = 0")
    add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  end
end

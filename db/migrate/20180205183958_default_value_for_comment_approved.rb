class DefaultValueForCommentApproved < ActiveRecord::Migration[5.1]
  def change
    change_column :comments, :approved, :boolean, null: false, default: "f"
  end
end

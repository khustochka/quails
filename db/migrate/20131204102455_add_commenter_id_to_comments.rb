class AddCommenterIdToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :commenter_id, :integer, null: true
  end
end

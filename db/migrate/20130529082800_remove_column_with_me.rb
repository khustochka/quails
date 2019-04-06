class RemoveColumnWithMe < ActiveRecord::Migration[4.2]
  def change
    remove_column :cards, :with_me
  end
end

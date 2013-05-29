class RemoveColumnWithMe < ActiveRecord::Migration
  def change
    remove_column :cards, :with_me
  end
end

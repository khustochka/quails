class MoveSocialToMeta < ActiveRecord::Migration[4.2]
  def change
    remove_column :pages, :likable
  end
end

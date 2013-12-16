class MoveSocialToMeta < ActiveRecord::Migration
  def change
    remove_column :pages, :likable
  end
end

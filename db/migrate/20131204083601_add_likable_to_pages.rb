class AddLikableToPages < ActiveRecord::Migration
  def change
    add_column :pages, :likable, :boolean, default: 'f'
  end
end

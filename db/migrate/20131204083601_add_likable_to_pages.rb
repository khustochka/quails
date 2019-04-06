class AddLikableToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :likable, :boolean, default: 'f'
  end
end

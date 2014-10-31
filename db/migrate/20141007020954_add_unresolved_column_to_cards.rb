class AddUnresolvedColumnToCards < ActiveRecord::Migration
  def change
    add_column :cards, :resolved, :boolean, null: false, default: 'f'
  end
end

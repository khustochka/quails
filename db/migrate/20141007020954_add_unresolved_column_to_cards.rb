class AddUnresolvedColumnToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :resolved, :boolean, null: false, default: 'f'
  end
end

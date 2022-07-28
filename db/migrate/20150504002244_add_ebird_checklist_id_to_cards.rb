class AddEBirdChecklistIdToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :ebird_id, :string, null: true, length: 16
  end
end

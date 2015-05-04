class AddEbirdChecklistIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :ebird_id, :string, null: true, length: 16
  end
end

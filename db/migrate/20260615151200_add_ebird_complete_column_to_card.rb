class AddEBirdCompleteColumnToCard < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :ebird_complete, :boolean, default: nil
  end
end

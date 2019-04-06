class BlankCardNotes < ActiveRecord::Migration[4.2]
  def up
    Card.where(notes: nil).update_all(notes: '')
    change_column :cards, :notes, :text, null: false, default: ''
  end

  def down
  end
end

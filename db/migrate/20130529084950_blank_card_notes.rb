class BlankCardNotes < ActiveRecord::Migration
  def up
    Card.where(notes: nil).update_all(notes: '')
    change_column :cards, :notes, :text, null: false, default: ''
  end

  def down
  end
end

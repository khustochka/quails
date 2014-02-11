class AddUsefulFieldsToCard < ActiveRecord::Migration
  def change
    add_column :cards, :effort_type, :string
    add_column :cards, :duration_minutes, :integer
    add_column :cards, :distance_kms, :float
    add_column :cards, :area, :float
    rename_column :cards, :time, :start_time
    change_column :cards, :start_time, :string, length: 5
    remove_column :cards, :route
  end
end

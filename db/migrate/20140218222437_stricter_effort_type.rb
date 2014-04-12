class StricterEffortType < ActiveRecord::Migration
  def change
    change_column :cards, :effort_type, :string, default: 'INCIDENTAL', null: false
  end
end

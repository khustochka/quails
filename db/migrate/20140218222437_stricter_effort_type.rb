class StricterEffortType < ActiveRecord::Migration[4.2]
  def change
    change_column :cards, :effort_type, :string, default: 'INCIDENTAL', null: false, limit: 255
  end
end

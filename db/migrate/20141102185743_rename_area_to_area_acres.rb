class RenameAreaToAreaAcres < ActiveRecord::Migration[4.2]
  def change
    rename_column :cards, :area, :area_acres
  end
end

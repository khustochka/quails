class RenameAreaToAreaAcres < ActiveRecord::Migration
  def change
    rename_column :cards, :area, :area_acres
  end
end

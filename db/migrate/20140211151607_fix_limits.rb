class FixLimits < ActiveRecord::Migration[4.2]
  def change
    change_column :cards, :start_time, :string, limit: 5
    change_column :loci, :iso_code, :string, limit: 3
  end
end

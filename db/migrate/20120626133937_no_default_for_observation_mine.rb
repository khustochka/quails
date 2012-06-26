class NoDefaultForObservationMine < ActiveRecord::Migration
  def up
    change_column_default(:observations, :mine, nil)
  end

  def down
    change_column_default(:observations, :mine, true)
  end
end

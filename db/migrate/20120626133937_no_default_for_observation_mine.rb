class NoDefaultForObservationMine < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:observations, :mine, nil)
  end

  def down
    change_column_default(:observations, :mine, true)
  end
end

class RemoveBiotope < ActiveRecord::Migration[4.2]
  def up
    Observation.where("place IS NULL OR place = ''").update_all('place = biotope')
    remove_column :observations, :biotope
  end

  def down
  end
end

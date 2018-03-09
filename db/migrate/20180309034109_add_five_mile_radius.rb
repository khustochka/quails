class AddFiveMileRadius < ActiveRecord::Migration[5.1]
  def change
    add_column :loci, :five_mile_radius, :boolean, default: false, null: false
  end
end

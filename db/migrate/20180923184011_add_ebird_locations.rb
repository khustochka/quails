class AddEBirdLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :ebird_locations do |t|
      t.string :name, null: false
      t.string :country_state
      t.string :county
      t.float :latitude
      t.float :longtitude
    end

    add_column :loci, :ebird_location_id, :integer, null: true
  end
end

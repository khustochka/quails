class CreateObservations < ActiveRecord::Migration
  def self.up
    create_table :observations do |t|
      t.integer :species_id
      t.integer :locus_id
      t.date :observ_date, :null =>false
      t.string :quantity
      t.string :biotope
      t.string :place
      t.string :notes
      t.boolean :mine, :default => true
    end
  end

  def self.down
    drop_table :observations
  end
end

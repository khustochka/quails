class CreatePatches < ActiveRecord::Migration
  def change
    create_table :patches do |t|
      t.string :name, null: false, unique: true
      t.float :lat
      t.float :lng

      t.datetime :created_at
    end

    add_column :observations, :patch_id, :integer

    Locus.where(patch: true).each do |loc|
      p = Patch.create(name: loc.name_en, lat: loc.lat, lng: loc.lon)
      obs = Observation.joins(:card).where('cards.locus_id' => loc.id)
      obs.update_all(patch_id: p.id)
      #obs.map(&:card).each {|card| card.update_attributes(locus_id: loc.parent_id) }
    end

  end
end

class AddLegacySlugToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :legacy_slug, :string

    add_index "species", ["legacy_slug"], :name => "index_species_on_legacy_slug", :unique => true

    sql = "UPDATE species SET legacy_slug = replace(name_sci, ' ', '_')"
    ActiveRecord::Base.connection.execute(sql)

    change_column :species, :legacy_slug, :string, :null => false
  end
end

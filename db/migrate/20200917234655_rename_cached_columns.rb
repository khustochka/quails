class RenameCachedColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :loci, :city_id, :cached_city_id
    rename_column :loci, :subdivision_id, :cached_subdivision_id
    rename_column :loci, :country_id, :cached_country_id
  end
end

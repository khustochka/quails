class AddCacheColumnsForLocus < ActiveRecord::Migration[6.1]
  def change
    add_column :loci, :cached_parent_id, :bigint, null: true
    add_column :loci, :city_id, :bigint, null: true
    add_column :loci, :subdivision_id, :bigint, null: true
    add_column :loci, :country_id, :bigint, null: true

    Locus.all.each(&:save!)

  end
end

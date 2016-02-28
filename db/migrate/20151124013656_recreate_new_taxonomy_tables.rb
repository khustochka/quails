class RecreateNewTaxonomyTables < ActiveRecord::Migration
  def up
    %w(legacy_taxa legacy_species ebird_taxa).each do |tb|
      drop_table tb if ActiveRecord::Base.connection.table_exists? tb
    end

    rename_table :species, :legacy_species
    rename_table :taxa, :legacy_taxa

    create_table :taxa do |t|
      t.string :name_sci, null: false
      t.string :name_en, null: false
      t.string :name_ru
      t.string :category, null: false
      t.string :order
      t.string :family
      t.integer :index_num, null: false
      t.string :ebird_code, null: false
      t.integer :parent_id
      t.integer :species_id
      t.integer :ebird_taxon_id
    end

    create_table :ebird_taxa do |t|
      t.string :name_sci, null: false
      t.string :name_en, null: false
      t.string :name_ioc_en, null: false
      t.string :category, null: false
      t.string :ebird_code, null: false
      t.string :order
      t.string :family
      t.string :ebird_order_num_str
      t.integer :index_num, null: false
      t.integer :parent_id
    end

    create_table :species do |t|
      t.string :name_sci, null: false
      t.string :name_en, null: false
      t.string :name_ru
      t.string :name_uk
      t.string :name_fr
      t.string :code, limit: 6
      t.string :legacy_code, limit: 6
      t.string :order, null: false
      t.string :family, null: false
      t.integer :index_num, null: false
    end
  end

  def down
    drop_table :species
    drop_table :taxa
    drop_table :ebird_taxa
    rename_table :legacy_species, :species
  end
end

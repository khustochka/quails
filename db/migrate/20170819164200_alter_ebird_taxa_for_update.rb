class AlterEBirdTaxaForUpdate < ActiveRecord::Migration[5.1]
  def change
    change_column :ebird_taxa, :name_ioc_en, :string, null: true
    add_column :ebird_taxa, :ebird_version, :smallint, null: false, default: 2016
    change_column :ebird_taxa, :ebird_version, :smallint, null: false, default: nil
  end
end

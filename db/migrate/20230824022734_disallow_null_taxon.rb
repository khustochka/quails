class DisallowNullTaxon < ActiveRecord::Migration[7.0]
  def change
    change_column :observations, :taxon_id, :integer, null: false
  end
end

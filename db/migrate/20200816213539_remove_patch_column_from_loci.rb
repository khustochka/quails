class RemovePatchColumnFromLoci < ActiveRecord::Migration[6.1]
  def change
    remove_column :loci, :patch, :boolean, default: 'f', null: false
  end
end

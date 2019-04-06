class AddColumnsToLoci < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :loc_type, :string, limit: 255
    add_column :loci, :name_format, :string, null: false, default: '', limit: 255
  end
end

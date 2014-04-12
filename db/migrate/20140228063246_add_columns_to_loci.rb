class AddColumnsToLoci < ActiveRecord::Migration
  def change
    add_column :loci, :loc_type, :string
    add_column :loci, :name_format, :string, null: false, default: ''
  end
end

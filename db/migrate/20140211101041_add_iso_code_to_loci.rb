class AddIsoCodeToLoci < ActiveRecord::Migration
  def change
    add_column :loci, :iso_code, :string, length: 3
  end
end

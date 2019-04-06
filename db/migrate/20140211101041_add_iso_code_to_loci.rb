class AddIsoCodeToLoci < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :iso_code, :string, length: 3
  end
end

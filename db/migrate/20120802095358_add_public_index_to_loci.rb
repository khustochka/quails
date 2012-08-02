class AddPublicIndexToLoci < ActiveRecord::Migration
  def change
    add_column :loci, :public_index, :integer, default: nil, null: true
  end
end

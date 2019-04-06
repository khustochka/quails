class AddPublicIndexToLoci < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :public_index, :integer, default: nil, null: true
  end
end

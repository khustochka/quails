class AddAncestryToLoci < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :ancestry, :string, limit: 255
    add_index :loci, :ancestry

    Locus.build_ancestry_from_parent_ids!
    Locus.check_ancestry_integrity!
  end
end

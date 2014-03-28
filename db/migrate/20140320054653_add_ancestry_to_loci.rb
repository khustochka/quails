class AddAncestryToLoci < ActiveRecord::Migration
  def change
    add_column :loci, :ancestry, :string
    add_index :loci, :ancestry

    Locus.build_ancestry_from_parent_ids!
    Locus.check_ancestry_integrity!
  end
end

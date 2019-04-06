class LociIsPluralForLocus < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :locus, :loci
  end

  def self.down
    rename_table :loci, :locus
  end
end

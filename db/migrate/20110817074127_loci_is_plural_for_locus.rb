class LociIsPluralForLocus < ActiveRecord::Migration
  def self.up
    rename_table :locus, :loci
  end

  def self.down
    rename_table :loci, :locus
  end
end

class LociToLocus < ActiveRecord::Migration
  def self.up
    rename_table :loci, :locus 
  end

  def self.down
    rename_table :locus, :loci
  end
end

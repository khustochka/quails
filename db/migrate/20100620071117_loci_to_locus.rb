class LociToLocus < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :loci, :locus
  end

  def self.down
    rename_table :locus, :loci
  end
end

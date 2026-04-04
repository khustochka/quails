# frozen_string_literal: true

class AddCachedPublicLocusToLoci < ActiveRecord::Migration[8.1]
  class Locus < ActiveRecord::Base
    has_ancestry orphan_strategy: :restrict

    def compute_public_locus_id
      if !private_loc
        id
      else
        ancestors.to_a.rfind { |l| !l.private_loc }&.id
      end
    end
  end

  def change
    add_column :loci, :cached_public_locus_id, :bigint, null: true

    Locus.find_each do |locus|
      locus.update_column(:cached_public_locus_id, locus.compute_public_locus_id)
    end

    add_index :loci, :cached_public_locus_id
    add_foreign_key :loci, :loci, column: :cached_public_locus_id
  end
end

# frozen_string_literal: true

class NormalizeLocusLocType < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE loci SET loc_type = NULL WHERE loc_type = ''"
  end

  def down
    # no-op
  end
end

class AddCacheColumnsForLocus < ActiveRecord::Migration[6.1]

  class Locus < ActiveRecord::Base

    has_ancestry orphan_strategy: :restrict
    def cache_parent_loci
      anc = self.ancestors.to_a
      cnt_id = anc.find {|l| l.loc_type == "country" && !l.private_loc}&.id
      sub_id = anc.find {|l| l.loc_type.in?(%w(state oblast)) && !l.private_loc}&.id
      city_id = anc.find {|l| l.loc_type == "city" && !l.private_loc}&.id
      self.cached_parent_id = self.parent_id unless self.parent_id.in?([cnt_id, sub_id, city_id]) || self.parent.private_loc
      self.cached_city_id = city_id
      self.cached_subdivision_id = sub_id
      self.cached_country_id = cnt_id
      save!
    end
  end

  def change
    add_column :loci, :cached_parent_id, :bigint, null: true
    add_column :loci, :cached_city_id, :bigint, null: true
    add_column :loci, :cached_subdivision_id, :bigint, null: true
    add_column :loci, :cached_country_id, :bigint, null: true

    Locus.find_each(&:cache_parent_loci)

  end
end

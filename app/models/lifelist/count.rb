module Lifelist
  class Count < Base

    def bare_relation
      base.select("species_id, COUNT(DISTINCT observations.id) AS obs_count").group("species_id")
    end

    def get_records
      bare_relation.order(ordering).preload(:taxon => :species).to_a
    end

    def short_to_a
      bare_relation.to_a
    end

  end
end

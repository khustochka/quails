module Lifelist
  class Count < Base

    # TODO: simpler base
    def bare_relation
      base.select("species_id, COUNT(DISTINCT observations.id) AS obs_count").group("species_id")
    end

    def get_records
      bare_relation.preload(:species).to_a
    end

    def short_to_a
      bare_relation.to_a
    end

  end
end

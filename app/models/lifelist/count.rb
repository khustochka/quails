# frozen_string_literal: true

module Lifelist
  class Count < Base
    def bare_relation
      base.select("species_id, COUNT(DISTINCT observations.id) AS obs_count").group("species_id")
    end

    def get_records
      records = bare_relation.order(ordering).to_a
      # FIXME: workaround species preloader, because declaring species association on observation causes problems
      species_preload(records)
      records
    end

    def short_to_a
      bare_relation.to_a
    end

    private
    def species_preload(records)
      sp_ids = records.map(&:species_id)
      spcs = Species.where(id: sp_ids).index_by(&:id)
      records.each do |rec|
        rec.taxon = Taxon.new(species: spcs[rec.species_id])
      end
    end
  end
end

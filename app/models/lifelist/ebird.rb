module Lifelist
  class Ebird

    def initialize(sort: "by_date")
      @sort = sort || "by_date"
    end

    delegate :each, :map, :size, :blank?, to: :to_a

    def count
      ebird_species_ids.count
    end

    def to_a
      if @sort == "by_taxonomy"
        build_relation.joins(:taxon => :ebird_taxon).order(Arel.sql("ebird_taxa.index_num"))
      else
        build_relation.order(default_order)
      end
    end

    def version
      "v%s" % [EbirdTaxon.maximum(:ebird_version)]
    end

    private

    def default_order
      Arel.sql("observ_date DESC, to_timestamp(start_time, 'HH24:MI') DESC NULLS LAST, observations.created_at DESC")
    end

    def ebird_species_ids
      ebird_taxa.
          select("COALESCE(ebird_taxa.parent_id, ebird_taxa.id)").
          where("ebird_taxa.category = 'species' OR ebird_taxa.parent_id IS NOT NULL").
          distinct
    end

    def ebird_taxa
      EbirdTaxon.
          joins(:taxon).
          merge(taxa)
    end

    def taxa
      Taxon.joins(:observations)
    end

    def build_relation
      Observation.
          where(id: observation_ids).
          joins(:taxon, :card).
          preload(:patch, {:taxon => [:species, {:ebird_taxon => :parent}]}, {:card => :locus})
    end

    def observation_ids
      idx = Observation.
          joins(:card).
          order(default_order).
          preload(:taxon => {:ebird_taxon => :parent}).
          to_a.
          fast_index_by {|obs| obs.taxon.ebird_taxon&.nearest_species}
      idx.delete(nil)
      idx.values
    end

  end
end

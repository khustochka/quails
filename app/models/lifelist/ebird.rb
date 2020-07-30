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
        ebird_species.order(:index_num)
      else
        # TEMPORARY
        ebird_species.order(:index_num)
      end
    end

    def version
      "v%s" % [EbirdTaxon.maximum(:ebird_version)]
    end

    private

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

    def ebird_species
      EbirdTaxon.category_species.where(id: ebird_species_ids)
    end

    def taxa
      Taxon.joins(:observations)
    end
  end
end

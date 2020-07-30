module Lifelist
  class Ebird

    def count
      ebird_species_ids.count
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

    def taxa
      Taxon.joins(:observations)
    end

  end
end

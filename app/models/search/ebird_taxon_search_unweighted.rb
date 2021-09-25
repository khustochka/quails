# frozen_string_literal: true

module Search
  class EbirdTaxonSearchUnweighted < Unweighted
    def find
      return EbirdTaxon.none if @term.blank?
      rel = @base.
          select("ebird_taxa.*,
                          CASE
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank").
          where(filter_clause).
          order("rank ASC NULLS LAST, ebird_taxa.index_num").
          limit(results_limit)
    end

    private
    def searchable_fields
      %w(name_sci name_en name_ioc_en)
    end
  end
end

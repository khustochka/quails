# frozen_string_literal: true

module Search
  class TaxonSearchUnweighted < Unweighted
    def find
      return Taxon.none if @term.blank?
      rel = @base.
        select("taxa.*,
                          CASE
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(filter_clause).
        order("rank ASC NULLS LAST, taxa.index_num").
        limit(results_limit)
    end

    private

    def searchable_fields
      %w(name_sci name_ru name_en)
    end
  end
end

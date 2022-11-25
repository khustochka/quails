# frozen_string_literal: true

module Search
  class TaxonSearchWeighted < Weighted
    DEFAULT_LIMIT = 15

    def find
      return [] if @term.blank?

      rel = @base
        .select("DISTINCT id, name_sci, name_en, category, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank")
        .where(filter_clause)
        .order("rank ASC NULLS LAST, weight DESC NULLS LAST")
        .limit(results_limit)

      rel.map do |tx|
        {
          value: tx.to_label,
          cat: tx.category,
          id: tx.id,
        }
      end
    end

    private

    def searchable_fields
      %w(name_sci name_en)
    end
  end
end

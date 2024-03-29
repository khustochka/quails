# frozen_string_literal: true

module Search
  class LociSearch < Unweighted
    DEFAULT_LIMIT = 20

    def find
      return Locus.none if @term.blank?

      @base
        .select("loci.*,
                          CASE
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank")
        .where(filter_clause)
        .order("rank ASC NULLS LAST, loci.id")
        .limit(results_limit)
    end

    private

    def searchable_fields
      %w(name_en name_ru name_uk slug)
    end

    def primary_condition
      starts_with_condition(:name_en)
    end
  end
end

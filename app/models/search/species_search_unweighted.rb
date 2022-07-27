# frozen_string_literal: true

module Search
  class SpeciesSearchUnweighted < Unweighted
    def find
      return Species.none if @term.blank?

      rel = @base
        .select("species.*,
                          CASE
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank")
        .where(filter_clause)
        .order("rank ASC NULLS LAST, species.index_num")
        .limit(results_limit)
    end

    private

    def searchable_fields
      %w(name_sci name_ru name_en name_uk)
    end
  end
end

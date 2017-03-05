module Search

  class SpeciesSearch < Weighted

    def find
      return [] if @term.blank?
      rel = @base.
          select("DISTINCT name_sci, name_en, name_ru, name_uk, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank").
          where(filter_clause).
          order("rank ASC NULLS LAST, weight DESC NULLS LAST").
          limit(5)

      if rel.to_a.size < 5
        primary_condition2 = starts_with_condition("url_synonyms.name_sci")
        secondary_condition = full_blown_condition("url_synonyms.name_sci")
        rel2 = @base.
            joins(:url_synonyms).
            select("DISTINCT url_synonyms.name_sci as name_sci, name_en, name_ru, name_uk, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{primary_condition2} THEN 1
                              ELSE 2
                          END as rank").
            where(secondary_condition).
            order("rank ASC NULLS LAST, weight DESC NULLS LAST").
            limit(5 - rel.size)
        rel = rel.to_a.concat(rel2.to_a)
      end

      rel.map { |sp| SpeciesSearchResult.new(sp.name_sci, detect_name(sp)) }
    end

    private
    def detect_name(sp)
      @regex ||= /(^| |-|\()#{@term}/i
      if sp.name_sci =~ @regex
        sp.name
      elsif sp.name_en =~ @regex
        sp.name_en
      elsif sp.name_ru =~ @regex
        sp.name_ru
      elsif sp.name_uk =~ @regex
        sp.name_uk
      else
        raise "Not able to detect name #{sp.name_sci}"
      end
    end

    private
    def searchable_fields
      %w(name_sci name_ru name_en name_uk)
    end

  end
end

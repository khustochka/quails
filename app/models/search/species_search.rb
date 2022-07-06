# frozen_string_literal: true

module Search
  class SpeciesSearch < Weighted
    DEFAULT_LIMIT = 5

    SEARCH_RESULT_CLASS = SpeciesSearchResult

    DEFAULT_LOCALE_PRIORITY = [:en, :uk, :ru]

    def find
      return [] if @term.blank?

      rel = @base.
        select("DISTINCT id, name_sci, name_en, name_ru, name_uk, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{primary_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(filter_clause).
        order("rank ASC NULLS LAST, weight DESC NULLS LAST").
        limit(results_limit)

      if rel.to_a.size < results_limit
        found_ids = Species.from(rel).pluck(:id)
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
          where.not(url_synonyms: { species_id: found_ids }).
          order("rank ASC NULLS LAST, weight DESC NULLS LAST").
          limit(results_limit - rel.size)
        rel = rel.to_a.concat(rel2.to_a)
      end

      rel.map { |sp| self.class::SEARCH_RESULT_CLASS.new(sp.name_sci, detect_name(sp)) }
    end

    private

    def detect_name(sp)
      locale_priority = DEFAULT_LOCALE_PRIORITY.dup
      @options[:locale]&.to_sym.yield_self do |set_locale|
        if set_locale
          locale_priority.delete(set_locale)
          locale_priority.unshift(set_locale)
        end
      end
      @regex ||= /(^| |-|\()#{@term}/i
      if sp.name_sci&.match?(@regex)
        sp.name
      else
        loc = locale_priority.find {|lang| sp[:"name_#{lang}"]&.match?(@regex)}
        if loc
          sp[:"name_#{loc}"]
        else
          raise "Not able to detect name #{sp.name_sci}"
        end
      end
    end

    def searchable_fields
      %w(name_sci name_uk name_en name_ru)
    end
  end
end

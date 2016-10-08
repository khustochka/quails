class SpeciesSearchUnweighted

  FILTER = lambda do |term|
    %w(name_sci name_ru name_en name_uk).map do |field|
      Species.send(:sanitize_conditions,
                   ["#{field} ILIKE '%s%%' OR #{field} ILIKE '%% %s%%' OR #{field} ILIKE '%%-%s%%' OR #{field} ILIKE '%%(%s%%'", term, term, term, term])
    end.join(" OR ")
  end

  def initialize(base, term)
    @base = base
    @term = term.downcase
  end

  def find
    return Species.none if @term.blank?
    main_condition = Species.send(:sanitize_conditions, ["name_sci ILIKE '%s%%'", @term])
    rel = @base.
        select("species.*,
                          CASE
                              WHEN #{main_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(FILTER.call(@term)).
        order("rank ASC NULLS LAST, species.index_num").
        limit(50)

  end

end

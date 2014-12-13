class SpeciesSearch

  FILTER = lambda do |term|
    %w(name_sci name_ru name_en name_uk).map do |field|
      Species.send(:sanitize_conditions,
                   ["#{field} ILIKE '%s%%' OR #{field} ILIKE '%% %s%%' OR #{field} ILIKE '%%-%s%%'", term, term, term])
    end.join(" OR ")
  end

  def initialize(base, term)
    @base = base
    @term = term
  end

  def find
    return [] if @term.blank?
    main_condition = Species.send(:sanitize_conditions, ["name_sci ILIKE '%s%%'", @term])
    rel = @base.
        select("DISTINCT name_sci, name_en, name_ru, name_uk, weight,
                          CASE WHEN weight IS NULL THEN NULL
                              WHEN #{main_condition} THEN 1
                              ELSE 2
                          END as rank").
        where(FILTER.call(@term)).
        order("rank ASC NULLS LAST, weight DESC NULLS LAST").
        limit(5)

    rel.map { |sp| SpeciesSearchResult.new(sp.name_sci, detect_name(sp)) }
  end

  private
  def detect_name(sp)
    @regex ||= /(^| |-)#{@term}/i
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

end

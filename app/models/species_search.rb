class SpeciesSearch

  FILTER = lambda do |term|
    %w(name_sci name_ru name_en name_uk).map do |field|
      "#{field} ILIKE '#{term}%' OR #{field} ILIKE '% #{term}%' OR #{field} ILIKE '%-#{term}%'"
    end.join(" OR ")
  end

  def initialize(term)
    @term = term
  end

  def find
    return [] if @term.blank?
    rel = Species.
        select("DISTINCT name_sci, name_en, name_ru, name_uk").
        where(FILTER.call(@term)).
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

class SpeciesSearch

  FILTER = lambda do |term|
    %w(name_sci name_ru name_en name_uk).map do |field|
      "#{field} ILIKE '#{term}%' OR #{field} ILIKE '% #{term}%' OR #{field} ILIKE '%-#{term}%'"
    end.join(" OR ")
  end

  def self.find(term)
    return [] if term.blank?
    rel = Species.
        select("DISTINCT name_sci, name_en, name_ru, name_uk").
        where(FILTER.call(term)).
        limit(5)

    rel.map { |sp| SpeciesSearchResult.new(sp) }
  end

end

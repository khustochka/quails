class SpeciesSearch

  def self.find(term)
    return [] if term.blank?
    Species.
        select("name_sci, name_en, name_ru, name_uk").
        where("name_sci ILIKE '#{term}%' OR name_sci ILIKE '% #{term}%'").
        limit(5).
        map { |sp| SpeciesSearchResult.new(sp) }
  end

end

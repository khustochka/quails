class SpeciesSearch

  def self.find(term)
    Species.
        select("name_sci, name_en, name_ru, name_uk").
        where("name_sci ILIKE '#{term}%' OR name_sci ILIKE '% #{term}%'").
        map { |sp| SpeciesSearchResult.new(sp) }
  end

end

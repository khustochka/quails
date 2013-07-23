class SpeciesSearchResult < Struct.new(:name_sci, :name_ru)

  def initialize(sp)
    super(sp.name_sci, sp.name_ru)
  end

  def as_json(*options)
    {label: name_sci, url: "/species/#{Species.parameterize(name_sci)}"}
  end

end

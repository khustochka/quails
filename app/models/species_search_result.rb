class SpeciesSearchResult < Struct.new(:name_sci, :name)

  def initialize(sp)
    super(sp.name_sci, sp.name)
  end

  def as_json(*options)
    {label: name_sci, url: "/species/#{Species.parameterize(name_sci)}", name: name}
  end

end

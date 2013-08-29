class SpeciesSearchResult < Struct.new(:name_sci, :name)

  def as_json(*options)
    {label: name_sci, url: "/species/#{Species.parameterize(name_sci)}", name: name}
  end

end

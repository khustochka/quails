class SpeciesSearchResult < Struct.new(:name_sci, :name_ru)

  def initialize(sp)
    super(sp.name_sci, sp.name_ru)
  end

end

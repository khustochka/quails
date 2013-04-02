module SpeciesParameterizer
  def parameterize(str)
    str.gsub(' ', '_')
  end

  def humanize(str)
    str.gsub(/[ _+]+/, ' ').capitalize
  end
end

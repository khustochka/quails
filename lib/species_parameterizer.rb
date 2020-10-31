# frozen_string_literal: true

module SpeciesParameterizer
  def parameterize(str)
    str.tr(" ", "_")
  end

  def humanize(str)
    str.gsub(/[ _+]+/, " ").capitalize
  end
end

class SpeciesSearchResult < Struct.new(:name_sci, :name)

  def as_json(*options)
    locale_prefix = ''
    locale_prefix = "/#{I18n.locale}" unless I18n.default_locale?
    {label: name_sci, url: "#{locale_prefix}/species/#{Species.parameterize(name_sci)}", name: name}
  end

end

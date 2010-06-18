require 'lib/import/legacy/legacy_model'

module Legacy

  class Country < LegacyModel
    set_table_name 'country'
  end

  class Region < LegacyModel
    set_table_name 'region'
  end

  class Location < LegacyModel
    set_table_name 'location'
  end

end
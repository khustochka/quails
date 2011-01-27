require 'import/legacy/models/geography'

module Import
  class LocationImport
    extend LegacyInit

    def self.get_legacy
      
      require 'app/models/locus'

      init_legacy

      Legacy::Country.all.each do |country|
        Locus.create!({
                :code => country[:country_id],
                :loc_type => 'Country',
                :name_ru => conv_to_new(country[:country_name]),
                :parent_id => nil
        }) if Locus.find_by_code(country[:country_id]).nil?
      end

      Legacy::Region.all.each do |region|
        Locus.create!({
                :code => region[:reg_id],
                :loc_type => 'Region',
                :name_ru => conv_to_new(region[:reg_name]),
                :parent_id => Locus.find_by_code!(region[:country_id]).id
        }) if Locus.find_by_code(region[:reg_id]).nil?
      end

      Legacy::Location.all.each do |loc|
        (lat, lon) = loc[:latlon].split(',')
        Locus.create!({
                :code => loc[:loc_id].gsub('-', '_'),
                :loc_type => 'Location',
                :name_ru => conv_to_new(loc[:loc_name]),
                :parent_id => Locus.find_by_code!(loc[:reg_id]).id,
                :lat => (lat.try(:to_f)),
                :lon => (lon.try(:to_f))
        }) if Locus.find_by_code(loc[:loc_id].gsub('-', '_')).nil?
      end

    end

  end
end
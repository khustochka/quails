require 'lib/import/legacy/models/geography'
require 'app/models/locus'

module Import
  class LocationImport
    extend LegacyInit

    def self.get_legacy
	
	  init_legacy

      Legacy::Country.all.each do |country|
        Locus.create!({
                :code => country[:country_id],
                :loc_type => 'Country',
                :name_ru => enconv(country[:country_name]),
                :parent_id => nil
        })
      end

      Legacy::Region.all.each do |region|
        Locus.create!({
                :code => region[:reg_id],
                :loc_type => 'Region',
                :name_ru => enconv(region[:reg_name]),
                :parent_id => Country.find_by_code!(region[:country_id]).id
        })
      end

      Legacy::Location.all.each do |loc|
        (lat, lon) = loc[:latlon].split(',')
        Locus.create!({
                :code => loc[:loc_id].gsub('-','_'),
                :loc_type => 'Location',
                :name_ru => enconv(loc[:loc_name]),
                :parent_id => Region.find_by_code!(loc[:reg_id]).id,
                :lat => (lat.to_f rescue nil),
                :lon => (lon.to_f rescue nil)
        })
      end

    end

  end
end
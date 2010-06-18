require 'lib/import/legacy/models/geography'
require 'app/models/country'
require 'app/models/region'
require 'app/models/location'

module Import
  class LocationImport
    extend LegacyInit

    def self.get_legacy

      Legacy::Country.all.each do |country|
        Country.create!({
                :code => country[:country_id],
                :name_ru => enconv(country[:country_name]),
                :parent_id => nil
        })
      end

      Legacy::Region.all.each do |region|
        Region.create!({
                :code => region[:reg_id],
                :name_ru => enconv(region[:reg_name]),
                :parent_id => Country.find_by_code!(region[:country_id]).id
        })
      end

      Legacy::Location.all.each do |loc|
        (lat, lon) = loc[:latlon].split(',')
        Location.create!({
                :code => loc[:loc_id].gsub('-','_'),
                :name_ru => enconv(loc[:loc_name]),
                :parent_id => Region.find_by_code!(loc[:reg_id]).id,
                :lat => (lat.to_f rescue nil),
                :lon => (lon.to_f rescue nil)
        })
      end

    end

  end
end
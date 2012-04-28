require 'legacy/mapping'

module Legacy
  module Import
    class Locations

      def self.update_all(countries, regions, locs)
        update_countries(countries)
        update_regions(regions)
        update_locations(locs)
      end

      def self.update_countries(arr)
        Legacy::Mapping.refresh_locations
        puts "Updating countries..."
        arr.each do |country|
          Locus.create!({
                            code: country[:country_id],
                            loc_type: 0,
                            name_ru: country[:country_name],
                            parent_id: nil
                        }) if Legacy::Mapping.locations[country[:country_id]].nil?
        end
        puts "Done."
      end

      def self.update_regions(arr)
        Legacy::Mapping.refresh_locations
        puts "Updating regions..."
        arr.each do |region|
          Locus.create!({
                            code: region[:reg_id],
                            loc_type: 1,
                            name_ru: region[:reg_name],
                            parent_id: Legacy::Mapping.locations[region[:country_id]]
                        }) if Legacy::Mapping.locations[region[:reg_id]].nil?
        end
        puts "Done."
      end

      def self.update_locations(arr)
        Legacy::Mapping.refresh_locations
        puts "Updating locations..."
        arr.each do |loc|
          (lat, lon) = loc[:latlon].split(',')
          Locus.create!({
                            code: loc[:loc_id].gsub('-', '_'),
                            loc_type: 2,
                            name_ru: loc[:loc_name],
                            parent_id: Legacy::Mapping.locations[loc[:reg_id]],
                            lat: (lat.try(:to_f)),
                            lon: (lon.try(:to_f))
                        }) if Legacy::Mapping.locations[loc[:loc_id].gsub('-', '_')].nil?
        end
        puts "Done."
      end

    end
  end
end

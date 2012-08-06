require 'legacy/mapping'

module Legacy
  module Import
    module Spots

      def self.import_spots(spots)

        #Legacy::Mapping.refresh_posts

        puts 'Importing map...'

        table = BunchDB::Table.new('spots')
        column_names = Spot.column_names.reject { |e| e == 'id' }
        records = spots.map do |c|
          rec = HashWithIndifferentAccess.new(
              observation_id: c[:observ_id],
              lat: c[:lat],
              lng: c[:lng],
              zoom: c[:zoom],
              memo: c[:memo],
              exactness: Spot::EXACTNESS.index(c[:exact]),
              public: (c[:access] == 'public')
          )
          column_names.map { |cn| rec[cn] }
        end
        table.fill(column_names, records)
        puts "Done."
      end
    end
  end
end

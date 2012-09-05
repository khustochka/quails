require 'legacy/mapping'

module Legacy
  module Import
    module Spots

      def self.import_spots(spots)

        puts 'Importing map...'

        table = BunchDB::Table.new('spots')
        column_names = Spot.column_names
        records = spots.map.with_index do |c, i|
          rec = HashWithIndifferentAccess.new(
              id: i + 1,
              observation_id: c[:observ_id],
              lat: c[:lat],
              lng: c[:lng],
              zoom: c[:zoom],
              memo: c[:memo],
              exactness: Spot::EXACTNESS.index(c[:exact]),
              public: (c[:access] == 'public')
          )
          Legacy::Mapping.add_spot(c[:observ_id], c[:mark_id], rec[:id])
          column_names.map { |cn| rec[cn] }
        end
        table.fill(column_names, records)

        # Delete multi Spp spots and other spots with lost observations:
        Spot.where('observation_id NOT IN (SELECT id FROM observations)').delete_all

        puts "Done."
      end
    end
  end
end

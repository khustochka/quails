require 'legacy/mapping'

module Legacy
  module Import
    class Observations

      def self.import_observations(observations)

        Legacy::Mapping.refresh_locations
        Legacy::Mapping.refresh_species
        Legacy::Mapping.refresh_posts

        puts 'Importing observations...'

        observs = observations.reject { |el| el[:sp_id] == 'mulspp' }

        table = BunchDB::Table.new('observations')
        column_names = Observation.column_names
        records = observs.map do |ob|
          rec = HashWithIndifferentAccess.new(
              id: ob[:observ_id],
              species_id: ob[:sp_id] == 'incogt' ? 0 : Legacy::Mapping.species[ob[:sp_id]],
              locus_id: Legacy::Mapping.locations[ob[:loc_id].gsub('-', '_')],
              observ_date: ob[:ob_date],
              biotope: ob[:bt_id],
              quantity: ob[:quantity],
              place: ob[:place],
              notes: ob[:notes],
              post_id: (Legacy::Mapping.posts[ob[:post_id]] unless ob[:post_id].blank?),
              mine: ob[:mine]
          )
          column_names.map { |c| rec[c] }
        end
        table.fill(column_names, records)
        table.reset_pk_sequence!
        puts "Done."
      end
    end
  end
end

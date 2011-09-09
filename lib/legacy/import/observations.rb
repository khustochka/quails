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

        chunk = observs.size / 49

        observs.each_with_index do |ob, i|
          new_ob = Observation.new({
                                           :species_id => Legacy::Mapping.species[ob[:sp_id]],
                                           :locus_id => Legacy::Mapping.locations[ob[:loc_id].gsub('-', '_')],
                                           :observ_date => ob[:ob_date],
                                           :biotope => ob[:bt_id],
                                           :quantity => ob[:quantity],
                                           :place => ob[:place],
                                           :notes => ob[:notes],
                                           :post_id => ob[:post_id].blank? ? nil : Legacy::Mapping.posts[ob[:post_id]],
                                           :mine => ob[:mine]
                                   })
          new_ob.id = ob[:observ_id]
          new_ob.save!
          if (i + 1) % chunk == 0
            part = ((i + 1) / chunk)
            $stderr.write(('=' * part) + " #{part*2}%\r")
          end
        end

        ActiveRecord::Base.connection.execute("ALTER SEQUENCE observations_id_seq RESTART #{Observation.maximum(:id)+1}")


        $stderr.write(('=' * 50) + " 100%")
        puts "Done."
      end
    end
  end
end
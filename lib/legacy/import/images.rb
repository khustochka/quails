# encoding: utf-8

require 'legacy/mapping'

module Legacy
  module Import
    module Images

      def self.import_images(images, observations, species)

        Legacy::Mapping.refresh_species
        Legacy::Mapping.refresh_locations

        multi_obs = Hash[observations.select { |o| o[:sp_id] == 'mulspp' }.map { |o| [o[:observ_id], o] }]

        puts 'Importing images...'

        images.each do |im|
          img = Image.new({
                              slug: im[:img_id],
                              title: im[:img_title],
                              description: im[:img_descr],
                              created_at: Time.zone.parse(im[:add_date]),
                              index_num: im[:img_sort]
                          })
          obs = Observation.where(id: im[:observ_id])

          if obs.empty?
            m_ob = multi_obs[im[:observ_id]]
            puts "For multi-observation #{m_ob[:observ_id]} found:"
            loc_id = Legacy::Mapping.locations[m_ob[:loc_id].gsub('-', '_')]
            date = m_ob[:ob_date]

            obs = m_ob[:notes].split(',').map do |sp_code|
              potential_ob = Observation.where(species_id: Legacy::Mapping.species[sp_code],
                                               locus_id: loc_id,
                                               observ_date: date).all
              if potential_ob.size == 1
                puts "  #{sp_code}: #{potential_ob.first.id}"
                potential_ob.first
              else
                puts "several: #{potential_ob.join(', ')}. Enter the valid one:"
                Observation.find($stdin.gets)
              end
            end
          else
            # Set spot_id only for non-multi obs images (coz it would be difficult)
            img.spot_id = Legacy::Mapping.spots["#{im[:observ_id]}#{im[:mark_id]}"]
          end

          img.observations = obs
          img.save!
        end

        # Set main images for the species
        species.each do |sp|
          spcs = Legacy::Mapping.species[sp[:sp_id]]
          next if spcs.nil?
          sp_img = sp[:sp_img]
          img = Image.find_by_slug!(sp_img) if sp_img.present?
          Species.find(spcs).update_column(:image_id, img)
        end

        puts 'Done.'
      end
    end
  end
end

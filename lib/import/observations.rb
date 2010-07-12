require 'lib/import/legacy/models/observation'

module Import
  class ObservationImport
    extend LegacyInit

    def self.get_legacy
      
      require 'app/models/observation'
      require 'app/models/species'

      init_legacy

      Legacy::Observation.where("sp_id <> 'mulspp'").each do |ob|
        new_ob = Observation.new({
                :species_id => ob[:sp_id] == 'incogt' ? nil : Species.find_by_code(ob[:sp_id]).id,
                :locus_id => Locus.find_by_code(ob[:loc_id].gsub('-', '_')).id,
                :observ_date => ob[:ob_date],
                :biotope => ob[:bt_id],
                :quantity => conv_to_new(ob[:quantity]),
                :place => conv_to_new(ob[:place]),
                :notes => conv_to_new(ob[:notes]),
                :mine => ob[:mine]
        })
        new_ob.id = ob[:observ_id]
        new_ob.save!
      end
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE observations_id_seq RESTART #{Observation.maximum(:id)+1}")
    end

  end
end
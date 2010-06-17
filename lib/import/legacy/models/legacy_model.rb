module Legacy

  class LegacyModel < ActiveRecord::Base

    @@legacy_db_spec = YAML.load_file('config/database.yml')['legacy']

    def self.establish_legacy_connection
      establish_connection(@@legacy_db_spec)
    end
  end
  
end
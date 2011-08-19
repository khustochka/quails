require 'iconv'

module Legacy
  class Utils

    @@legacy_db_spec = YAML.load_file('config/database.yml')['legacy'] || {}
    @@rails_db_spec = YAML.load_file('config/database.yml')[Rails.env || 'development']

      # Iconv does not understand 'unicode'
    @@legacy_db_spec['encoding'] = 'utf-8' if @@legacy_db_spec['encoding'] == 'unicode'
    @@rails_db_spec['encoding'] = 'utf-8' if @@rails_db_spec['encoding'] == 'unicode'

    def self.prepare_table(raw)
      cols = raw['columns']
      raw['records'].map do |el|
        Hash[cols.zip(el)].symbolize_keys
      end
    end

    def self.conv_to_new(str)
      @@legacy_db_spec["encoding"] != @@rails_db_spec["encoding"] ?
              Iconv.iconv(@@rails_db_spec["encoding"], @@legacy_db_spec["encoding"], str).to_s :
              str
    end

    def self.conv_to_old(str)
      @@legacy_db_spec["encoding"] != @@rails_db_spec["encoding"] ?
              Iconv.iconv(@@legacy_db_spec["encoding"], @@rails_db_spec["encoding"], str).to_s :
              str
    end

    def self.db_connect
      Legacy::Models::Base.establish_connection(@@legacy_db_spec)
    end

  end
end
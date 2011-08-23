require 'iconv'

module Legacy
  class Utils

    def self.prepare_table(raw)
      cols = raw['columns']
      raw['records'].map do |el|
        Hash[cols.zip(el)].symbolize_keys
      end
    end

    def self.db_connect
      @@legacy_db_spec = YAML.load_file('config/database.yml')['legacy'] || {}
      #@@rails_db_spec = YAML.load_file('config/database.yml')[Rails.env || 'development']

      Legacy::Models::Base.establish_connection(@@legacy_db_spec)
    end

  end
end
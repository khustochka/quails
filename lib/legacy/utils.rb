require 'iconv'

module Legacy
  class Utils

    def self.prepare_table(raw)
      cols = raw['columns']
      raw['records'].map do |el|
        Hash[cols.zip(el)].symbolize_keys
      end
    end

    def self.db_connect(spec)
      Legacy::Models::Base.establish_connection(spec)
    end

  end
end

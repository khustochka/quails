require 'legacy/models/base'

module Legacy
  module Models

    class Country < Base
      self.table_name = 'country'
    end

    class Region < Base
      self.table_name = 'region'
    end

    class Location < Base
      self.table_name = 'location'
    end
  end

end

require 'legacy/models/base'

module Legacy
  module Models

    class Country < Base
      set_table_name 'country'
    end

    class Region < Base
      set_table_name 'region'
    end

    class Location < Base
      set_table_name 'location'
    end
  end

end
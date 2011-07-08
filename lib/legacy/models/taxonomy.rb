require 'legacy/models/base'

module Legacy
  module Models
    class Species < Base
      set_table_name 'species'
    end

    class Order < Base
      set_table_name 'ordines'
    end

    class Family < Base
      set_table_name 'familiae'
    end
  end
end
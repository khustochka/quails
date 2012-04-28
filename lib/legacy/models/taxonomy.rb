require 'legacy/models/base'

module Legacy
  module Models
    class Species < Base
      self.table_name = 'species'
    end

    class Order < Base
      self.table_name = 'ordines'
    end

    class Family < Base
      self.table_name = 'familiae'
    end
  end
end

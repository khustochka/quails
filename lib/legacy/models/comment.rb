require 'legacy/models/base'

module Legacy
  module Models
    class Comment < Base
      self.table_name = 'comments'
    end
  end
end

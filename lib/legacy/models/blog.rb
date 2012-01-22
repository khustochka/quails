require 'legacy/models/base'

module Legacy
  module Models
    class Post < Base
      self.table_name = 'blog'
    end
  end
end
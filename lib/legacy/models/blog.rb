require 'legacy/models/base'

module Legacy
  module Models
    class Post < Base
      set_table_name 'blog'
    end
  end
end
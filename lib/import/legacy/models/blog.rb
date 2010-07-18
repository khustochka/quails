require 'lib/import/legacy/legacy_model'

module Legacy
  class Post < LegacyModel
    set_table_name 'blog'
  end
end
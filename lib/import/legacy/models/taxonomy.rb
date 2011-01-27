require 'import/legacy/legacy_model'

module Legacy
  class Species < LegacyModel
    set_table_name 'species'
  end

  class Order < LegacyModel
    set_table_name 'ordines'
  end

  class Family < LegacyModel
    set_table_name 'familiae'
  end
end
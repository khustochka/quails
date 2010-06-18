require 'lib/import/legacy/legacy_init'

module Legacy

  class LegacyModel < ActiveRecord::Base
    include LegacyInit

    establish_connection(@@legacy_db_spec)

  end

end
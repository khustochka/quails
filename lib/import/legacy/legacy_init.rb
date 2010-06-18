require 'iconv'

module LegacyInit

  @@legacy_db_spec = YAML.load_file('config/database.yml')['legacy']
  @@rails_db_spec = YAML.load_file('config/database.yml')[Rails.env || 'development']

  # Iconv does not understand 'unicode'
  @@legacy_db_spec['encoding'] = 'utf-8' if @@legacy_db_spec['encoding'] == 'unicode'
  @@rails_db_spec['encoding'] = 'utf-8' if @@rails_db_spec['encoding'] == 'unicode'


  def enconv(str)
    @@legacy_db_spec["encoding"] != @@rails_db_spec["encoding"] ?
            Iconv.iconv(@@rails_db_spec["encoding"], @@legacy_db_spec["encoding"], str).to_s :
            str
  end

end
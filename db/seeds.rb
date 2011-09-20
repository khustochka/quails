# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# YAML::ENGINE.yamler= 'psych' # required for parsing db dump yaml in debugging mode

local_opts = YAML.load_file('config/local.yml')
dirname = File.join(local_opts['repo'], 'seed')


Dir[File.join(dirname, '*.yml')].each do |file|
  raw = YAML.load(File.new(file, "r")).to_a[0]
  table, data = *raw

  quoted_table_name = ActiveRecord::Base.connection.quote_table_name(table)

  ActiveRecord::Base.connection.execute("DELETE FROM #{quoted_table_name}")

  records = data['records']
  column_names = data['columns']
  columns = column_names.map { |cn| ActiveRecord::Base.connection.columns(table).detect { |c| c.name == cn } }

  quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')

  records.each_slice(1000) do |bunch|
    quoted_values = bunch.map { |rec| "(#{rec.zip(columns).map { |c| ActiveRecord::Base.connection.quote(c.first, c.last) }.join(',')})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES #{quoted_values}")
  end

  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end
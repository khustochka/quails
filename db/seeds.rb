# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'bunch_db/table'
require 'seed_tables'

local_opts = YAML.load_file('config/local.yml')
dirname = File.join(local_opts['repo'], 'seed')

SEED_TABLES.each do |table_name|
  raw = YAML.load(File.new "#{dirname}/#{table_name}.yml", "r").to_a[0]

  data = raw[1]

  table = BunchDB::Table.new(table_name)
  table.cleanup

  column_names = data['columns']
  records = data['records']

  table.fill(column_names, records)

  table.reset_pk_sequence!
end

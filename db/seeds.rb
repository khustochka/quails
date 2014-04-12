# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'bunch_db/table'
require 'seed_helper'

dirname = SEED_DIR

seed_init_if_necessary!

SEED_TABLES.each do |table_name|
  filename = "#{dirname}/#{table_name}.yml"

  raw = YAML.load(File.new(filename), "r").to_a[0]

  data = raw[1]

  table = BunchDB::Table.new(table_name)
  table.cleanup

  column_names = data['columns']
  records = data['records']

  table.fill(column_names, records)

  table.reset_pk_sequence!
end

#Page.create(slug: 'links', title: "Links", public: true, text: "Lorem ipsum")

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'yaml_db'

# YAML::ENGINE.yamler= 'psych' # required for parsing db dump yaml in debugging mode

local_opts = YAML.load_file('config/local.yml')

SerializationHelper::Base.new(YamlDb::Helper).load_from_dir File.join(local_opts['repo'], 'seed')
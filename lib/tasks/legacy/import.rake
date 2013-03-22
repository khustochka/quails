require 'legacy/import/locations'
require 'legacy/import/posts'
require 'legacy/import/observations'
require 'legacy/import/images'
require 'legacy/import/comments'
require 'legacy/import/spots'
require 'legacy/utils'


desc 'Legacy data tasks'
namespace :legacy do

  desc 'Pull the latest legacy dump from repository and import into DB'
  task :update => [:pull, :import]

  desc 'Fetch the latest legacy dump from site and import into DB'
  task :upgrade => [:fetch, :import]

  desc 'Fetch the legacy dump, and restore both legacy and new DB'
  task :full_backup => [:backup, :import]


  desc 'Importing data from legacy DB dump'
  task :import => 'load_locals' do

    raise "Do not purge the production DB!" if Rails.env.production?

    Rake::Task['db:setup'].invoke

    source = File.join(@folder, 'legacy', 'seed_data.yml')
    puts "Importing from #{source}"
    dump = File.open(source, encoding: 'windows-1251:utf-8') do |f|
      YAML.load(f.read)
    end
    species = Legacy::Utils.prepare_table(dump['species'])
    countries = Legacy::Utils.prepare_table(dump['country'])
    regions = Legacy::Utils.prepare_table(dump['region'])
    locs = Legacy::Utils.prepare_table(dump['location'])
    posts = Legacy::Utils.prepare_table(dump['blog'])
    comments = Legacy::Utils.prepare_table(dump['comments'])
    images = Legacy::Utils.prepare_table(dump['images'])
    spots = Legacy::Utils.prepare_table(dump['map'])

    source = File.join(@folder, 'legacy', 'field1_data.yml')
    puts "Importing from #{source}"
    dump1 = File.open(source, encoding: 'windows-1251:utf-8') do |f|
      YAML.load(f.read)
    end

    source = File.join(@folder, 'legacy', 'field2_data.yml')
    puts "Importing from #{source}"
    dump2 = File.open(source, encoding: 'windows-1251:utf-8') do |f|
      YAML.load(f.read)
    end

    obs_dump = {
            'columns' => dump1['observation']['columns'],
            'records' => dump1['observation']['records'] + dump2['observation']['records']
        }

    observations = Legacy::Utils.prepare_table(obs_dump)

    Legacy::Import::Locations.update_all(countries, regions, locs)

    Legacy::Import::Posts.import_posts(posts)

    Legacy::Import::Comments.import_comments(comments)

    Legacy::Import::Observations.import_observations(observations)

    Legacy::Import::Spots.import_spots(spots)

    Legacy::Import::Images.import_images(images, observations, species)

  end
end

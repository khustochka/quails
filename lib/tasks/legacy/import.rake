require 'legacy/import/locations'
require 'legacy/import/posts'
require 'legacy/import/observations'
require 'legacy/import/images'
require 'legacy/import/comments'
require 'legacy/import/spots'
require 'legacy/utils'

desc 'Legacy data tasks'
namespace :legacy do

  desc 'Importing data from legacy DB dump'
  task(:import => [:environment, 'db:setup']) do

    local_opts = YAML.load_file('config/local.yml')

    source = ENV['SOURCE']

    #require 'tasks/grit_init'
    folder = local_opts['repo']

    #repo = Grit::Repo.new(folder)

    #puts 'Pulling from remote'
    #repo.git.pull

    source = File.join(folder, 'legacy', 'seed_data.yml')
    puts "Importing from #{source}"
    dump = File.open(source, encoding: 'windows-1251:utf-8') do |f|
      YAML.load(f.read)
    end
    countries = Legacy::Utils.prepare_table(dump['country'])
    regions = Legacy::Utils.prepare_table(dump['region'])
    locs = Legacy::Utils.prepare_table(dump['location'])
    posts = Legacy::Utils.prepare_table(dump['blog'])
    comments = Legacy::Utils.prepare_table(dump['comments'])

    source = File.join(folder, 'legacy', 'field_data.yml')
    puts "Importing from #{source}"
    dump = File.open(source, encoding: 'windows-1251:utf-8') do |f|
      YAML.load(f.read)
    end
    observations = Legacy::Utils.prepare_table(dump['observation'])
    images = Legacy::Utils.prepare_table(dump['images'])
    spots = Legacy::Utils.prepare_table(dump['map'])

    Legacy::Import::Locations.update_all(countries, regions, locs)

    Legacy::Import::Posts.import_posts(posts)

    Legacy::Import::Comments.import_comments(comments)

    Legacy::Import::Observations.import_observations(observations)

    Legacy::Import::Images.import_images(images, observations)

    Legacy::Import::Spots.import_spots(spots)

  end
end

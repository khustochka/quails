require 'legacy/import/locations'
require 'legacy/import/posts'
require 'legacy/import/observations'
require 'legacy/import/images'
require 'legacy/utils'

desc 'Legacy data tasks'
namespace :legacy do

  # TODO: expand the task to work with Legacy DB directly (extract common code)
  desc 'Importing data from legacy DB dump'
  task(:import => [:environment, 'db:setup']) do

    source = ENV['SOURCE']

    if source.nil? || source == 'db'
      require 'legacy/models/blog'
      require 'legacy/models/geography'
      require 'legacy/models/observation'
      require 'legacy/models/image'
      Legacy::Utils.db_connect

      countries = Legacy::Models::Country.all
      regions = Legacy::Models::Region.all
      locs = Legacy::Models::Location.all
      posts = Legacy::Models::Post.all
      observations = Legacy::Models::Observation.all
      images = Legacy::Models::Image.all
    else
      f = File.open(source, encoding: 'windows-1251:utf-8')
      dump = YAML.load(f.read)
      countries = Legacy::Utils.prepare_table(dump['country'])
      regions = Legacy::Utils.prepare_table(dump['region'])
      locs = Legacy::Utils.prepare_table(dump['location'])
      posts = Legacy::Utils.prepare_table(dump['blog'])
      observations = Legacy::Utils.prepare_table(dump['observation'])
      images = Legacy::Utils.prepare_table(dump['images'])
    end

    Legacy::Import::Locations.update_all(countries, regions, locs)

    Legacy::Import::Posts.import_posts(posts)

    Legacy::Import::Observations.import_observations(observations)

    Legacy::Import::Images.import_images(images, observations)

  end
end
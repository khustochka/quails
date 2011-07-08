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

    # TODO: should be possible to specify file, or search for it in the predictable location, or fetch URL
    dump = YAML::load_file('tmp/db_dump.yml')

    countries = Legacy::Utils.prepare_table(dump['country'])
    regions = Legacy::Utils.prepare_table(dump['region'])
    locs = Legacy::Utils.prepare_table(dump['location'])
    Legacy::Import::Locations.update_all(countries, regions, locs)

    posts = Legacy::Utils.prepare_table(dump['blog'])
    Legacy::Import::Posts.import_posts(posts)

    observations = Legacy::Utils.prepare_table(dump['observation'])
    Legacy::Import::Observations.import_observations(observations)

    images = Legacy::Utils.prepare_table(dump['images'])
    Legacy::Import::Images.import_images(images, observations)

  end
end
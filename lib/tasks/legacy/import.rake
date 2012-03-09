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

    if source.nil? && local_opts['database']
      puts 'Importing from the legacy DB'

      require 'legacy/models/blog'
      require 'legacy/models/geography'
      require 'legacy/models/observation'
      require 'legacy/models/image'
      require 'legacy/models/comment'
      require 'legacy/models/spot'
      Legacy::Utils.db_connect(local_opts['database'])

      countries = Legacy::Models::Country.all
      regions = Legacy::Models::Region.all
      locs = Legacy::Models::Location.all
      posts = Legacy::Models::Post.all
      observations = Legacy::Models::Observation.all
      images = Legacy::Models::Image.all
      comments = Legacy::Models::Comment.all
      spots = Legacy::Models::Spot.all
    else
      if source.nil?
        #require 'tasks/grit_init'
        folder = local_opts['repo']

        #repo = Grit::Repo.new(folder)

        #puts 'Pulling from remote'
        #repo.remote_fetch('origin')

        source = File.join(folder, 'legacy', 'db_dump.yml')
      end

      puts "Importing from #{source}"

      f = File.open(source, encoding: 'windows-1251:utf-8')
      dump = YAML.load(f.read)
      countries = Legacy::Utils.prepare_table(dump['country'])
      regions = Legacy::Utils.prepare_table(dump['region'])
      locs = Legacy::Utils.prepare_table(dump['location'])
      posts = Legacy::Utils.prepare_table(dump['blog'])
      observations = Legacy::Utils.prepare_table(dump['observation'])
      images = Legacy::Utils.prepare_table(dump['images'])
      comments = Legacy::Utils.prepare_table(dump['comments'])
      spots = Legacy::Utils.prepare_table(dump['map'])
    end

    Legacy::Import::Locations.update_all(countries, regions, locs)

    Legacy::Import::Posts.import_posts(posts)

    Legacy::Import::Comments.import_comments(comments)

    Legacy::Import::Observations.import_observations(observations)

    Legacy::Import::Images.import_images(images, observations)

    Legacy::Import::Spots.import_spots(spots)

  end
end
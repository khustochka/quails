require 'import/blog'
require 'import/observations'

desc 'Importing data'
namespace :import do

  desc 'Importing blog posts from legacy DB'
  task(:blog => :environment) do

    puts 'Importing blog posts from legacy DB'
    Import::BlogImport.get_posts

  end

  desc 'Importing observations data from legacy DB'
  task(:observations_legacy => :environment) do

    puts 'Importing observations data from legacy DB'
    Import::ObservationImport.get_legacy

  end

  desc 'Tasks for importing field data: blog posts, observations'
  task(:field_data => [:blog, :observations_legacy]) do

  end
end

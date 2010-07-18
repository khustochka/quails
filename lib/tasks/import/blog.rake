require File.join(Rails.root, 'lib/import/blog')

desc 'Tasks for importing blog posts'
namespace :import do

  desc 'Importing blog posts from legacy DB'
  task(:blog => :environment) do

    Import::BlogImport.get_posts

  end
end

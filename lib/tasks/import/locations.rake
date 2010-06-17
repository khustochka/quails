require File.join(Rails.root, 'lib/import/locations')

desc 'Tasks for importing locations'
namespace :import do

  desc 'Importing geographical data from legacy DB'
  task(:locations_legacy => :environment) do

    Import::Location.get_legacy

  end
end

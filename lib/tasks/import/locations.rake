require 'import/locations'

desc 'Tasks for importing locations'
namespace :import do

  desc 'Importing geographical data from legacy DB'
  task(:locations_legacy => :environment) do

    Import::LocationImport.get_legacy

  end
end

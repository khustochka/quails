require 'import/locations'

desc 'Importing data'
namespace :import do

  desc 'Importing geographical data from legacy DB'
  task(:locations_legacy => :environment) do

    Import::LocationImport.get_legacy

  end
end

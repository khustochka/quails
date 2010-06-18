require File.join(Rails.root, 'lib/import/observations')

desc 'Tasks for importing observations'
namespace :import do

  desc 'Importing observations data from legacy DB'
  task(:observations_legacy => :environment) do

    Import::ObservationImport.get_legacy

  end
end

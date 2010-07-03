require 'lib/import/species'

desc 'Exporting data to legacy db'
namespace :export do

  desc 'Exporting species from new DB to legacy MySQL one'
  task :species => :environment do
    Import::SpeciesImport.export
  end
end

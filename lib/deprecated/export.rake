#require 'import/species'

desc 'Legacy data tasks'
namespace :legacy do
  desc 'Exporting data to legacy db'
  namespace :export do

    desc 'Exporting species from new DB to legacy MySQL one'
    task :species => :environment do
      Import::SpeciesImport.export
    end
  end
end

#require 'import/species'

desc 'Importing data'
namespace :import do

  desc 'Import the species from Avibase site'
  namespace :species do

    desc 'Import basic species data from Avibase site'
    task :basics => :environment do

      include ChecklistsHelper

      puts 'Importing species'

      regions = %w(  ua usny usnj  )

      holarctic = Import::SpeciesImport.parse_list(avibase_list_url('hol', ENV['list'] || 'clements'))

      desired = regions.map do |reg|
        Import::SpeciesImport.parse_list(avibase_list_url(reg, ENV['list'] || 'clements'))
      end.uniq

      desired2 = holarctic & desired

      puts 'Missing:'
      (desired.uniq - holarctic).each do |sp|
        puts sp.inspect
      end

      puts 'DB filling started'

      Import::SpeciesImport.fill_db(desired2)

    end

    desc 'Import species details from Avibase site'
    task :details => :environment do
      Import::SpeciesImport.fetch_details
    end

    desc 'Create mapping of legacy DB species to the new ones'
    task :map => :environment do
      Import::SpeciesImport.create_mapping
    end

    desc "Import the species' code from the legacy DB"
    task :codes => :environment do
      Import::SpeciesImport.import_codes
    end
  end

end
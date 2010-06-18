require 'lib/import/species'
#require 'app/helpers/checklists_helper'

desc 'Importing data'
namespace :import do

  desc 'Import the species from Avibase site'
  namespace :species do

    desc 'Import basic species data from Avibase site'
    task :basics => :environment do

      include ChecklistsHelper

      puts 'Importing species'

      regions = %w(  ua usny usnj  )

      holarctic = Import::SpeciesImport.parse_list(avibase_list_url('hol'))

      desired = regions.inject([]) do |memo, reg|
        memo + Import::SpeciesImport.parse_list(avibase_list_url(reg))
      end

      desired = holarctic & desired

      puts 'DB filling started'

      Import::SpeciesImport.fill_db(desired)

    end

    desc 'Import species details from Avibase site'
    task :details => :environment do
      Import::SpeciesImport.fetch_details(desired)
    end

    desc 'Create mapping of legacy DB species to the new ones'
    task :map => :environment do
      Import::SpeciesImport.create_mapping('lib/import/legacy/species_map.yml')
    end
  end

end
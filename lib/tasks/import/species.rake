require 'lib/import/species'

desc 'Importing data'
namespace :import do

  desc 'Import the species from Avibase site'
  task :species => :environment do

    puts "Importing species"
    full_list = 'http://avibase.bsc-eoc.org/checklist.jsp?region=hol&list=clements&lang=EN'

    regions = %w(  ua usny usnj  )

    holarctic = Import::Species.list(full_list)

    desired = regions.inject([]) do |memo, reg|
      memo + Import::Species.list(full_list.sub('hol', reg))
    end

    desired = holarctic & desired

    desired.inject(1) do |index_num, sp|
      Species.create(
              :name_sci => sp[:name_sci],
              :name_en => sp[:name_en],
              :avibase_id => sp[:avibase_id],
              :index_num => index_num
      )
      index_num + 1
    end

  end

end
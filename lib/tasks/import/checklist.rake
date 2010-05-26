require 'lib/import/checklist'

desc 'Importing data'
namespace :import do
  
  desc 'Import the checklists from avibase files to yaml'
  namespace :checklist do

    desc "Importing all checklists"
    task :all => [:ukraine, :usa, :usny] do
    end

    desc "Importing Ukraine's checklist"
    task :ukraine do
      puts "Importing Ukraine's checklist"
      file = File.new('lib/import/input/clements_ua_ru.html', 'r')
      Import::Checklist.parse(file, 'lib/import/output/ukraine.yaml')
    end

    desc "Importing USA checklist"
    task :usa do
      puts "Importing USA checklist"
      file = File.new('lib/import/input/clements_us_ru.html', 'r')
      Import::Checklist.parse(file, 'lib/import/output/usa.yaml')
    end

    desc "Importing New York checklist"
    task :usny do
      puts "Importing New York checklist"
      file = File.new('lib/import/input/clements_usny_ru.html', 'r')
      Import::Checklist.parse(file, 'lib/import/output/usa_ny.yaml')
    end
  end
end
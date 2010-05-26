require 'lib/import/checklist'

desc 'Importing data'
namespace :import do
  
  desc 'Import the checklists from avibase files to yaml'
  namespace :checklist do

    desc "Importing all checklists"
    task :all => [:ukraine, :usa] do
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
  end
end
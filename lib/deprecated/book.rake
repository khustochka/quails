#require 'import/book'

desc 'Importing data'
namespace :import do

  desc 'Import the authorities lists'
  namespace :book do

    desc "Importing Clements book"
    task :clements do
      puts 'Importing Clements book'
      Import::Book::Clements.parse('lib/import/output/clements.yaml')
    end

  end

end

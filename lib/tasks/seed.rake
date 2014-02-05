require 'seed_helper'

desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => [:environment] do

    require 'bunch_db/table'

    dirname = SEED_DIR

    SEED_TABLES.each do |table_name|
      puts "Dumping '#{table_name}'..."
      io = File.new "#{dirname}/#{table_name}.yml", "w"
      table = BunchDB::Table.new(table_name)
      table.dump(io)
      io.close
    end

    puts "\nGit diff:\n"

    system("git diff #{dirname} #{dirname}")

  end

end

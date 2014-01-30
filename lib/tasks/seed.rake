require 'seed_tables'

desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => [:environment] do

    require 'bunch_db/table'

    dirname = File.join(Rails.root, 'db', 'seed')

    SEED_TABLES.each do |table_name|
      puts "Dumping '#{table_name}'..."
      io = File.new "#{dirname}/#{table_name}.yml", "w"
      table = BunchDB::Table.new(table_name)
      table.dump(io)
      io.close
    end

    puts "\nGit diff:\n"

    system("git diff #{dirname}")

  end

end

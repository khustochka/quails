require 'seed_helper'

desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => [:environment] do

    require 'bunch_db/table'

    dirname = SEED_DIR

    seed_init_if_necessary!

    SEED_TABLES.each do |table_name|
      puts "Dumping '#{table_name}'..."
      io = File.new File.join(dirname, "#{table_name}.yml"), "w"
      table = BunchDB::Table.new(table_name)
      table.dump(io)
      io.close
    end

    msg = "Seed update #{Time.now}"

    Dir.chdir(SEED_DIR) do
      if ENV["DEBUG"].nil? || ENV["DEBUG"] == "false"
        system("git add *.yml")
        system("git commit -m '#{msg}'")
        system("git push origin master")
      else
        system "git diff"
      end
    end


  end

end

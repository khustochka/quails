require 'seed_tables'

desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => ['helper:pull', :environment] do

    require 'bunch_db/table'

    dirname = File.join(@folder, 'seed')

    Dir.chdir(@folder) do
      SEED_TABLES.each do |table_name|
        puts "Dumping '#{table_name}'..."
        io = File.new "#{dirname}/#{table_name}.yml", "w"
        table = BunchDB::Table.new(table_name)
        table.dump(io)
        io.close
        @repo.add("seed/#{table_name}.yml")
      end
    end


    puts 'Committing: ', msg = "Data seed #{Time.current.strftime('%F %T')}"
    @repo.commit_index(msg)

    puts 'Pushing to remote'
    @repo.git.push

  end

  desc 'Update the repo and load the seed (removing other data)'
  task :load => ['helper:pull', :environment] do

    raise "Do not purge the production DB!" if Rails.env.production?

    Rake::Task['db:setup'].invoke
  end

end

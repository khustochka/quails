desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => :environment do

    require 'tasks/grit_init'
    require 'bunch_db/table'

    tables = %w(species loci checklists)

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    Dir.chdir(folder) do
      repo.git.pull
    end

    dirname = File.join(folder, 'seed')

    Dir.chdir(folder) do
      tables.each do |table_name|
        puts "Dumping '#{table_name}'..."
        io = File.new "#{dirname}/#{table_name}.yml", "w"
        table = BunchDB::Table.new(table_name)
        table.dump(io)
        repo.add("seed/#{table_name}.yml")
      end
    end

    puts 'Committing: ', msg = "Data seed #{Time.current.strftime('%F %T')}"
    repo.commit_index(msg)

    puts 'Pushing to remote'
    repo.git.push

  end

  desc 'Update the repo and load the seed (removing other data)'
  task :load => :environment do

    require 'tasks/grit_init'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    Dir.chdir(folder) do
      repo.git.pull
    end

    Rake::Task['db:setup'].invoke
  end

end

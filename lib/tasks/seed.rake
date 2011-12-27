desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task backup: :environment do

    require 'grit'
    require 'bunch_db/table'

    tables = %w(species loci)

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.remote_fetch('origin')

    dirname = File.join(folder, 'seed')

    Dir.chdir(folder) do
      tables.each do |table_name|
        puts "Dumping '#{table_name}'..."
        io = File.new "#{dirname}/#{table_name}.yml", "w"
        table = BunchDB::Table.new(table_name)
        table.dump(io)
        repo.add("seed/#{table}.yml")
      end
    end

    puts 'Committing: ', msg = "Data seed #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    repo.commit_index(msg)

    puts 'Pushing to remote'
    repo.git.push

  end

  desc 'Update the repo and load the seed (removing other data)'
  task load: :environment do

    require 'grit'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.remote_fetch('origin')

    Rake::Task['db:setup'].invoke
  end

end
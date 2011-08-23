desc 'Tasks for managing DB seed'
namespace :seed do

  desc 'Backup the seed'
  task :backup => :environment do

    require 'grit'
    require 'yaml_db'

    tables = %w(species loci)

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.remote_fetch('origin')

    dirname = File.join(folder, 'seed')
    dumper = YamlDb::Dump

    Dir.chdir(folder) do
      tables.each do |table|
        puts "Dumping '#{table}'..."
        io = File.new "#{dirname}/#{table}.yml", "w"
        dumper.before_table(io, table)
        dumper.dump_table io, table
        dumper.after_table(io, table)
        repo.add("seed/#{table}.yml")
      end
    end

    puts 'Committing: ', msg = "Data seed #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    repo.commit_index(msg)

    puts 'Pushing to remote'
    repo.git.push

  end

end
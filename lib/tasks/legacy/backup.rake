desc 'Legacy data tasks'
namespace :legacy do

  desc 'Download and backup legacy DB dump'
  task :backup => :environment do

    require 'grit'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']
    spec = local_opts['remote']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.remote_fetch('origin')

    filename = File.join(folder, 'legacy', 'db_dump.yml')

    auth = "--basic -u #{spec['user']}:#{spec['password']}" if spec["user"] && spec["password"]
    system "curl #{auth} #{spec['url']} > #{filename}"

    Dir.chdir(folder) do
      repo.add("legacy/db_dump.yml")
    end

    puts 'Committing: ', msg = "DB backup #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    repo.commit_index(msg)

    puts 'Pushing to remote'
    repo.git.push
  end

  desc 'Restore legacy DB dump into local DB'
  task :restore => :environment do

    require 'grit'
    require 'yaml_db'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.remote_fetch('origin')

    filename = File.join(folder, 'legacy', 'db_dump.yml')

    ActiveRecord::Base.establish_connection(local_opts['database'])
    puts "Loading #{filename}..."

    # NOTE: legacy DB connection encoding showuld be utf8 for this to work!
    file = File.open(filename, encoding: 'windows-1251')
    ydoc = YAML.load(file.read)
    ydoc.keys.each do |table_name|
      next if ydoc[table_name].nil?
      YamlDb::Load.load_table(table_name, ydoc[table_name], true)
    end

  end

end

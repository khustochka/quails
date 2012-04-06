desc 'Legacy data tasks'
namespace :legacy do

  desc 'Download legacy DB dump, and restore it locally'
  task :backup => [:fetch, :restore]

  desc 'Download legacy DB dump, and push it to remote repo'
  task :fetch => :environment do

    require 'tasks/grit_init'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']
    spec = local_opts['remote']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.git.pull

    filename = File.join(folder, 'legacy', 'db_dump.yml')

    auth = "--basic -u #{spec['user']}:#{spec['password']}" if spec["user"] && spec["password"]
    system "curl #{auth} #{spec['url']} > #{filename}"

    Dir.chdir(folder) do
      repo.add("legacy/db_dump.yml")
    end

    puts 'Committing: ', msg = "DB backup #{Time.zone.now.strftime('%F %T')}"
    repo.commit_index(msg)

    puts 'Pushing to remote'
    repo.git.push
  end

  desc 'Restore legacy DB dump into local DB'
  task :restore => :environment do

    require 'tasks/grit_init'
    require 'bunch_db/table'

    local_opts = YAML.load_file('config/local.yml')
    folder = local_opts['repo']

    repo = Grit::Repo.new(folder)

    puts 'Pulling from remote'
    repo.git.pull

    filename = File.join(folder, 'legacy', 'db_dump.yml')

    ActiveRecord::Base.establish_connection(local_opts['database'])
    puts "Loading #{filename}..."

    # NOTE: legacy DB connection encoding should be utf8 for this to work!
    file = File.open(filename, encoding: 'windows-1251')
    ydoc = YAML.load(file.read)
    ydoc.keys.each do |table_name|
      data = ydoc[table_name]
      next if data.nil?

      table = BunchDB::Table.new(table_name)
      table.cleanup

      column_names = data['columns']
      records = data['records']

      table.fill(column_names, records)
    end

  end

end

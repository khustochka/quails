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
    Dir.chdir(folder) do
      repo.git.pull
    end


    auth = "--basic -u #{spec['user']}:#{spec['password']}" if spec["user"] && spec["password"]

    %w(seed field1 field2).each do |aspect|
      filename = File.join(folder, 'legacy', "#{aspect}_data.yml")
      system "curl #{auth} #{spec['url']}?data=#{aspect} --silent --show-error -o #{filename}"
    end

    Dir.chdir(folder) do
      repo.add("legacy/*.yml")
    end

    puts 'Committing: ', msg = "DB backup #{Time.current.strftime('%F %T')}"
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

    # NOTE: legacy DB connection encoding should be utf8 for this to work!
    ActiveRecord::Base.establish_connection(local_opts['database'])

    filename = File.join(folder, 'legacy', 'seed_data.yml')
    puts "Loading #{filename}..."
    dump1 = File.open(filename, encoding: 'windows-1251') do |file|
      YAML.load(file.read)
    end

    filename = File.join(folder, 'legacy', 'field1_data.yml')
    puts "Loading #{filename}..."
    dump2 = File.open(filename, encoding: 'windows-1251') do |file|
      YAML.load(file.read)
    end

    filename = File.join(folder, 'legacy', 'field2_data.yml')
    puts "Loading #{filename}..."
    dump3 = File.open(filename, encoding: 'windows-1251') do |file|
      YAML.load(file.read)
    end

    obs_dump = {
        'columns' => dump2['observation']['columns'],
        'records' => dump2['observation']['records'] + dump3['observation']['records']
    }

    ydoc = dump1.merge!({'observation' => obs_dump})


    ydoc.each_key do |table_name|
      data = ydoc[table_name]
      next unless data

      table = BunchDB::Table.new(table_name)
      table.cleanup

      column_names = data['columns']
      records = data['records']

      table.fill(column_names, records)
    end

  end

end

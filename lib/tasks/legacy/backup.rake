desc 'Legacy data tasks'
namespace :legacy do
  
  task :load_locals do
    @local_opts = YAML.load_file('config/local.yml')
    @folder = @local_opts['repo']
    @spec = @local_opts['remote']
  end

  task :init_repo => :load_locals do
    require 'tasks/grit_init'
    @repo = Grit::Repo.new(@folder)
  end

  desc 'Pull the legacy data from remote repository'
  task :pull => :init_repo do

    puts 'Pulling from remote'
    Dir.chdir(@folder) do
      @repo.git.pull
    end
  end


  desc 'Download legacy DB dump, and restore it locally'
  task :backup => [:fetch, :restore]


  desc 'Download legacy DB dump, and push it to remote repo'
  task :fetch => [:pull, :environment] do

    auth = "--basic -u #{@spec['user']}:#{@spec['password']}" if @spec["user"] && @spec["password"]

    silence = Quails.env.background? ? "--silent --show-error" : ""

    %w(seed field1 field2).each do |aspect|
      filename = File.join(@folder, 'legacy', "#{aspect}_data.yml")
      puts "Getting #{aspect}_data.yml"
      system "curl #{auth} #{@spec['url']}?data=#{aspect} #{silence} -o #{filename}"
    end

    Dir.chdir(@folder) do
      @repo.add("legacy/*.yml")
    end

    puts 'Committing: ', msg = "DB backup #{Time.current.strftime('%F %T')}"
    @repo.commit_index(msg)

    puts 'Pushing to remote'
    @repo.git.push
  end

  desc 'Restore legacy DB dump into local legacy DB'
  task :restore => [:pull, :environment] do

    require 'bunch_db/table'

    # NOTE: legacy DB connection encoding should be utf8 for this to work!
    ActiveRecord::Base.establish_connection(@local_opts['database'])

    filename = File.join(@folder, 'legacy', 'seed_data.yml')
    puts "Loading #{filename}..."
    dump1 = File.open(filename, encoding: 'windows-1251') do |file|
      YAML.load(file.read)
    end

    filename = File.join(@folder, 'legacy', 'field1_data.yml')
    puts "Loading #{filename}..."
    dump2 = File.open(filename, encoding: 'windows-1251') do |file|
      YAML.load(file.read)
    end

    filename = File.join(@folder, 'legacy', 'field2_data.yml')
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

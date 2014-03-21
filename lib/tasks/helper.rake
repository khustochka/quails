namespace :helper do

  task :load_locals do
    @db_spec = YAML.load_file('config/database.yml')[ENV['RAILS_ENV'] || 'development']
    @local_opts = YAML.load_file('config/local.yml')
    @folder = @local_opts['repo']
  end

  desc 'Pull the legacy data from remote repository'
  task :pull => :load_locals do
    puts 'Pulling from remote'
    Dir.chdir(@folder) do
      system 'git pull'
    end
  end

end

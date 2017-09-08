namespace :helper do

  task :load_locals do
    @db_spec = YAML.load_file('config/database.yml')[ENV['RAILS_ENV'] || 'development']
    @local_opts = YAML.load_file('config/local.yml')
    begin
      @folder = @local_opts["repo"]
    rescue
      raise "DB backup folder should be at `repo` key in `config/local.yml`"
    end
  end

  desc 'Pull the legacy data from remote repository'
  task :pull => :load_locals do
    puts 'Pulling from remote'
    Dir.chdir(@folder) do
      system 'git pull'
    end
  end

end

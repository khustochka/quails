namespace :helper do

  task :load_locals do
    @db_spec = Rails.configuration.database_configuration[Rails.env]
    begin
      @local_opts = YAML.load_file('config/local.yml')
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

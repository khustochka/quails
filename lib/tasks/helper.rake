namespace :helper do

  task :load_locals do
    @db_spec = Rails.configuration.database_configuration[Rails.env]
    begin
      @folder = ENV['DATA_REPO'] || (!Rails.env.production? && File.join(Dir.home, "bwdata"))
      raise "DB backup folder should be set with DATA_REPO env var" unless @folder.present?
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

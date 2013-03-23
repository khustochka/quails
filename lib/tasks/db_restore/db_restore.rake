desc 'DB restore data tasks'
namespace :db do

  desc 'Restore local db from existing dump'
  task :restore => 'helper:load_locals' do
    raise "Do not destroy production DB!" if ENV['RAILS_ENV'] == 'production'
    exec %Q(pg_restore -v -d #{@db_spec['database']} -O -x -n public --clean -U #{@db_spec['username']} #{@folder}/prod/prod_db_dump)
  end

  desc 'Fetch db dump from the repo and restore the db'
  task :update => ['helper:pull', :restore]

  namespace :helper do

    task :load_locals do
      @db_spec = YAML.load_file('config/database.yml')[ENV['RAILS_ENV'] || 'development']
      @local_opts = YAML.load_file('config/local.yml')
      @folder = @local_opts['repo']
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

  end

end
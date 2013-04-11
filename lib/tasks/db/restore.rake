desc 'DB restore data tasks'
namespace :db do

  desc 'Restore local db from existing dump'
  task :restore => 'helper:load_locals' do
    cli = %Q(pg_restore -v -d #{@db_spec['database']} -O -x -n public --clean -U #{@db_spec['username']} #{@folder}/prod/prod_db_dump)
    raise "You will destroy production DB!\nIf sure, type\n  #{cli}" if ENV['RAILS_ENV'] == 'production'
    exec cli
  end

  desc 'Fetch db dump from the repo and restore the db'
  task :update => ['helper:pull', :restore]

end

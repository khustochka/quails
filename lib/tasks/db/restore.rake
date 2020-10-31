# frozen_string_literal: true

desc "DB restore data tasks"
namespace :db do
  desc "Restore local db from existing dump"
  task restore: "helper:load_locals" do
    custom_db = ENV["DATABASE_NAME"]
    cli = %Q(pg_restore -v -d #{custom_db || @db_spec['database']} -O -x -n public #{custom_db ? "--clean" : ""} -U #{@db_spec['username']} #{@folder}/prod/prod_db_dump)

    # Testing for production db is done by Rails.
    if custom_db
      puts "Trying to restore a custom DB. You may need to drop/recreate it."
      system cli
    else
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      system cli
      Rake::Task["db:environment:set"].invoke
    end
  end

  desc "Fetch db dump from the repo and restore the db"
  task update: ["helper:pull", :restore]
end

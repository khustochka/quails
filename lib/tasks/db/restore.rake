# frozen_string_literal: true

desc "DB restore data tasks"
namespace :db do
  desc "Restore local db from existing dump"
  task restore: :environment do
    custom_db = ENV["DATABASE_NAME"]
    dump_file = ENV["DB_DUMP"]
    if dump_file.blank?
      puts "Provide a DB dump file path in DB_DUMP env var"
      exit(1)
    end
    db_spec = Rails.configuration.database_configuration[Rails.env]
    cli = %Q(pg_restore -v -d #{custom_db || db_spec["database"]} -O -x -n public #{"--clean" if custom_db} -U #{db_spec["username"]} #{dump_file})

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
end

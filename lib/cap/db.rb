namespace :db do
  desc 'Restore the database from local backup'
  task :restore, :roles => :db do
    run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} legacy:import }
  end
end

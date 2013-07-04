namespace :db do
  namespace :test do
    desc 'Causes db:test:load to also run db:seed'
    # If you create a rake task with the
    # same name as another one (in this case test:db:prepare), it will
    # be run after the first one. That's how this works.
    task :load do

      ENV['RAILS_ENV'] = 'test'
      Rake::Task['db:seed'].invoke
    end
  end
end

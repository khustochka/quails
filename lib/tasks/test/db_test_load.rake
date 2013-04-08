namespace :db do
  namespace :test do
    desc 'Causes db:test:load to also run db:seed'
    # If you create a rake task with the
    # same name as another one (in this case test:db:prepare), it will
    # be run after the first one. That's how this works.
    task :prepare => 'db:abort_if_pending_migrations' do
      ENV['RAILS_ENV'] = 'test'
      Rake::Task['db:seed'].invoke

      # Remove species image_id's before testing (no images in test DB)
      Species.update_all(image_id: nil)

    end
  end
end

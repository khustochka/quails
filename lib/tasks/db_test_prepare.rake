# Taken from http://github.com/look/fixie
namespace :db do
  namespace :test do
    desc 'Causes db:test:prepare to also run db:seed'
    # If you create a rake task with the
    # same name as another one (in this case test:db:prepare), it will
    # be run after the first one. That's how this works.
    task :prepare do
      Rake::Task['db:seed'].invoke
#      RAILS_ENV = 'test'
#      Dir[File.join(RAILS_ROOT, 'test', 'fixie', '*.rb')].sort.each { |fixture| load fixture }
    end
  end
end
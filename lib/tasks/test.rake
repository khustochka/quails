# desc 'Run tests'
# If you create a rake task with the
# same name as another one (in this case :test), it will
# be run after the first one.
task :test do
  Rake::Task['cucumber'].invoke
end
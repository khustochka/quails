# desc 'Run tests'
# If you create a rake task with the
# same name as another one (in this case :test), it will
# be run after the first one.

# FIXME: Disabled because it is not working properly in RubyMine 3.1.1
# (some conflict with RubyMine patch for Minitest)
# task :test do
#   Rake::Task['cucumber'].invoke
# end
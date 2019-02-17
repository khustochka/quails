task :test do

  Rake::Task["test:system"].invoke

end

# FIXME: `bin/rake test` runs all, but `bin/rails test` does not
# for this use `bin/rails test:all`

namespace :test do

  task :all => [:test]

end

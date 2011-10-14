# if you ever need DB use Rake::TestTask.new('test:flickr' => 'test:prepare')

Rake::TestTask.new('test:flickr') do |t|
  t.libs << 'test'
  t.pattern = 'test/flickr/**/*_test.rb'
end
Rake::Task['test:flickr'].comment = "Test flickr functionality"


namespace :test do
  desc 'Run only unit and functional tests'
  task :fast do
    tests_to_run = ENV['TEST'] ? ["test:single"] : %w(test:units test:functionals)
    errors = tests_to_run.collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors * ', '}!" if errors.any?
  end
end
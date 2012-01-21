namespace :test do

  desc 'Runs unit, functional and integration tests without test:prepare'
  task :fast do
    tests_to_run = ENV['TEST'] ? ["test:fast:single"] : %w(test:fast:units test:fast:functionals test:fast:integration)
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

  namespace :fast do

    desc 'Run only unit and functional tests'
    task :internal do
      tests_to_run = ENV['TEST'] ? ["test:fast:single"] : %w(test:fast:units test:fast:functionals)
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

    Rake::TestTask.new(:single) do |t|
      t.libs << "test"
    end

    Rails::SubTestTask.new(:units) do |t|
      t.libs << "test"
      t.pattern = 'test/unit/**/*_test.rb'
    end

    Rails::SubTestTask.new(:functionals) do |t|
      t.libs << "test"
      t.pattern = 'test/functional/**/*_test.rb'
    end

    Rails::SubTestTask.new(:integration) do |t|
      t.libs << "test"
      t.pattern = 'test/integration/**/*_test.rb'
    end

  end

end

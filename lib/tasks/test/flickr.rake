# frozen_string_literal: true

# if you ever need to restore DB
# use Rake::TestTask.new('test:flickr' => 'test:prepare')

require "rake/testtask"

Rake::TestTask.new("test:flickr") do |t|
  t.libs << "test"
  t.pattern = "test/flickr/**/*_test.rb"
end
Rake::Task["test:flickr"].comment = "Test flickr functionality"

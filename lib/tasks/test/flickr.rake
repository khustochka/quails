# if you ever need to retore DB
# use Rake::TestTask.new('test:flickr' => 'test:prepare')

Rake::TestTask.new('test:flickr') do |t|
  t.libs << 'test'
  t.pattern = 'test/flickr/**/*_test.rb'
end
Rake::Task['test:flickr'].comment = "Test flickr functionality"

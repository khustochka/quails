source :rubygems

gem 'rails', '3.1.0'

gem 'pg', :platforms => [:ruby, :mingw]

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

gem 'thin', :group => :production, :require => false, :platforms => :ruby # for heroku

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'haml-rails'
gem 'sass'
gem 'kaminari'
gem 'meta_search'
gem 'rails_autolink'
gem 'simple_form'
# using specific yaml_db, because the canonic gem works bad with new psych format
# see https://github.com/ludicast/yaml_db/pull/24
gem 'yaml_db', :git => 'git://github.com/bseanvt/yaml_db.git', :ref => '14ebdb79805d71501fbd', :require => false
gem 'hashie'
gem 'flickraw', :require => false

group :development do
  gem 'rails3-generators'
  gem 'nokogiri', :platforms => [:ruby, :mingw], :require => false
  gem 'mysql2', '~>0.3.7', :platforms => :ruby, :require => false
  gem 'grit', :require => false

# Other gems that may be useful but are not really dependencies:
# gem 'ruby-debug-ide' # for debugging in RubyMine
# gem 'unicorn' # web server
# gem 'heroku'  # for Heroku deployment
# gem 'taps'    # for pushing DB to Heroku
end

group :test do
  gem 'test-unit'
  gem 'ruby-prof', :platforms => :ruby, :require => false
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-expectations', :require => false # No need to require on startup b/c TestUnitTestCase doesn't exist then
  gem 'launchy' # So you can do Then show me the page
  #platforms :ruby, :mingw do
  #  gem 'spork'
  #end
end

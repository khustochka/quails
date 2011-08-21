source :rubygems

gem 'rails', '3.0.10'

gem 'pg', :platforms => [:ruby, :mingw]

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'haml-rails'
gem 'sass'
gem 'kaminari'
gem 'meta_search'
gem 'simple_form'
gem 'yaml_db'
gem 'hashie'
gem 'flickraw', :require => false

group :development do
  gem 'rails3-generators'
  gem 'nokogiri', :platforms => [:ruby, :mingw], :require => nil
  gem 'mysql2', '~>0.2.7', :platforms => :ruby, :require => nil

# Other gems that may be useful but are not really dependencies:
# gem 'ruby-debug-ide' # for debugging in RubyMine
# gem 'unicorn' # web server
# gem 'heroku'  # for Heroku deployment
# gem 'taps'    # for pushing DB to Heroku
end

group :test do
  gem 'test-unit'
  gem 'ruby-prof', :platforms => :ruby, :require => nil
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'rspec-expectations', :require => false # No need to require on startup b/c TestUnitTestCase doesn't exist then
  gem 'launchy' # So you can do Then show me the page
  gem 'pickle'
  platforms :ruby, :mingw do
    gem 'spork'
  end
end

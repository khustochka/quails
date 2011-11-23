source :rubygems

gem 'rails', '3.1.3'

gem 'pg', :platforms => [:ruby, :mingw]

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

gem 'thin', :group => :production, :require => false, :platforms => :ruby # for heroku

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'haml-rails'
gem 'sass'
gem 'kaminari'
gem 'ransack'
gem 'rails_autolink'
gem 'simple_form'
gem 'hashie'
gem 'flickraw', '0.8.4', :require => false

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
  gem 'ruby-prof', :require => false
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'rspec-expectations', :require => false # No need to require on startup b/c TestUnitTestCase doesn't exist then
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', :require => false
#  gem 'spork-testunit'
end

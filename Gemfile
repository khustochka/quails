source 'http://rubygems.org'

mingw = (Bundler::VERSION < '1.0.5') ? [] : [:mingw]

gem 'rails', '3.0.3'

gem 'pg', :platforms => [:ruby, :mswin] + mingw

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'haml', '~> 3.0'
gem "will_paginate", "~> 3.0.pre2"
gem 'simple_form'
gem 'yaml_db'
gem 'hashie'

group :development do
  gem 'rails3-generators'
  platforms *([:ruby, :mswin] + mingw) do
    gem 'mysql2', :require => nil
    gem 'nokogiri', :require => nil
  end

# Other gems that may be useful but are not really dependencies:
# gem 'ruby-debug-ide' # for debugging in RubyMine
# gem 'unicorn' # web server
# gem 'heroku'  # for Heroku deployment
# gem 'taps'    # for pushing DB to Heroku
end

group :test do
  gem 'ruby-prof', :platforms => :ruby, :require => nil
  gem 'shoulda'
  #gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails', :git => 'git://github.com/aslakhellesoy/cucumber-rails.git'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'launchy' # So you can do Then show me the page
  gem 'pickle'
  platforms *([:ruby, :mswin] + mingw) do
    gem 'spork'
  end
end
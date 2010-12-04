source 'http://rubygems.org'

gem 'rails', '3.0.1'

gem 'pg', :platforms => [:ruby, :mswin, :mingw]

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'haml', '~> 3.0'
gem "will_paginate", "~> 3.0.pre2"
gem 'formtastic'
gem 'simple_form'
gem 'yaml_db'

group :development do
  gem 'rails3-generators'
  platforms :ruby, :mswin, :mingw do
    gem 'mysql', :require => nil
    gem 'nokogiri', :require => nil
  end
end

group :test do
  gem 'shoulda'
  #gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'launchy' # So you can do Then show me the page
  gem 'pickle'
  platforms :ruby, :mswin, :mingw do
    gem 'spork'
  end
end

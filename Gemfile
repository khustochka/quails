source :rubygems

ruby '1.9.3'

gem 'rails', '3.2.8'
# gem 'rails', github: 'rails/rails'

gem 'pg', :platforms => [:ruby, :mingw]

gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

group :production do
  gem 'thin', :require => false
  gem 'eventmachine', '~> 1.0.0.rc', :require => false
end

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'rails-i18n'
gem 'haml-rails'
gem 'RedCloth'
gem 'kaminari'
gem 'rails_autolink'
gem 'simple_form', '~> 2.0'
gem 'flickraw', '~> 0.9.5', :require => false
gem 'flickraw-cached'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rails3-generators'
  gem 'nokogiri', :platforms => [:ruby, :mingw], :require => false
  gem 'mysql2', '~> 0.3.7', :platforms => :ruby, :require => false

  gem 'grit', '~> 2.5', :require => false, :platforms => [:ruby, :mingw]

# Other gems that may be useful but are not really dependencies:
# gem 'ruby-debug-ide' # for debugging in RubyMine
# gem 'unicorn' # web server
# gem 'heroku'  # for Heroku deployment
# gem 'taps'    # for pushing DB to Heroku
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', :groups => [:development, :test]

group :test do
  gem 'test-unit'
  gem 'ruby-prof', :require => false, :platforms => [:mri, :mingw]
  gem 'capybara'
  gem 'rspec-expectations', :require => false # No need to require on startup b/c TestUnitTestCase doesn't exist then
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', :require => false
#  gem 'spork-testunit'
end

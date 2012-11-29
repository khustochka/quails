source :rubygems

ruby '1.9.3'

gem 'rails', '3.2.9'
# gem 'rails', github: 'rails/rails'

gem 'pg', :platforms => [:ruby, :mingw]
gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby

gem 'thin', :require => false, :groups => [:development, :heroku], :platforms => [:ruby, :mingw]

gem 'airbrake', require: false
gem 'newrelic_rpm', groups: [:production]

group :vps do
  gem 'unicorn', :require => false, :platforms => :ruby
  #gem 'puma', :require => false, :platforms => :ruby
end

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
  gem 'turbo-sprockets-rails3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: [:ruby]

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rails3-generators'
  gem 'nokogiri', :platforms => [:ruby, :mingw], :require => false
end

group :development, :vps do
  gem 'grit', '~> 2.5', :require => false, :platforms => [:ruby, :mingw]
  gem 'mysql2', '~> 0.3.7', :platforms => :ruby, :require => false
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', :groups => [:development, :test]

group :test do
  gem 'test-unit'
  gem 'ruby-prof', :require => false, :platforms => [:mri, :mingw]
  gem 'capybara', '~> 2.0'
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', :require => false, :platforms => [:ruby, :mingw]
end

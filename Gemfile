source 'https://rubygems.org/'

ruby '2.3.1'

gem 'rails', '4.2.6'

gem 'pg', platforms: [:ruby, :mingw]
#gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

# Deployment
#gem 'unicorn', require: false, platforms: :ruby
gem "puma"
gem 'dotenv-rails'

# Translations
gem 'rails-i18n'

# Old rails functionality
gem 'actionpack-page_caching'

# AR utils
gem 'ancestry'
gem 'ordered-active-record'

# Templating
gem "haml", "~> 4.0.4"
gem 'haml-rails'
gem 'haml-contrib'
gem 'RedCloth'
gem 'rinku'

# Improved functionality utils
gem 'kaminari'
gem 'simple_form'

# External services
gem 'flickraw', '~> 0.9.7'
gem 'livejournal', '~> 0.3.9'

# Small utils
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'

# Monitoring
gem 'airbrake', require: false
gem 'newrelic_rpm'

# Assets
gem "sprockets-rails"
gem 'jquery-rails'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'benchmark-ips'
  gem "foreman"
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', groups: [:development, :test]

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
#  gem 'database_cleaner', '~> 1.3.0', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

source 'https://rubygems.org/'

ruby '2.3.3'

#gem 'rails', '5.0.1'
VERSION = "5.0.1"
gem "activesupport", VERSION
gem "actionpack",    VERSION
gem "actionview",    VERSION
gem "activemodel",   VERSION
gem "activerecord",  VERSION
gem "actionmailer",  VERSION
gem "railties",      VERSION

gem 'pg', platforms: [:ruby, :mingw]
#gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

# Deployment
#gem 'unicorn', require: false, platforms: :ruby
gem "puma"
gem 'dotenv-rails'

# Translations
gem 'rails-i18n'

# Old rails functionality
gem "actionpack-page_caching", "~> 1.1"
gem "rails-controller-testing"

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
gem "high_voltage"

# External services
gem 'flickraw', '~> 0.9.7'
gem 'livejournal', '~> 0.3.9'

# Small utils
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'

# Monitoring
gem 'airbrake'
gem 'newrelic_rpm'

# Assets
gem "sprockets-rails"
gem 'jquery-rails'
gem 'pjax_rails', git: "https://github.com/khustochka/pjax_rails.git", branch: "trailing-ampersand-fix"
gem 'respond-js-rails'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails'
gem 'font-awesome-sass'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
  gem 'benchmark-ips'
  gem "foreman"
end


group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  # in dev group for generators
  gem 'factory_girl_rails', '~> 4.0'
end

group :test do
  gem 'capybara'
  # This is a driver for headless JS tests (default).
  gem 'capybara-webkit'
  # And this one is if you want to see it in a real browser.
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
#  gem 'database_cleaner', '~> 1.3.0', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

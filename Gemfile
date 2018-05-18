source 'https://rubygems.org/'

ruby '2.5.1'

VERSION = "5.2.0"
gem 'rails', VERSION
# gem "activesupport", VERSION
# gem "actionpack",    VERSION
# gem "actionview",    VERSION
# gem "activemodel",   VERSION
# gem "activerecord",  VERSION
# gem "activejob",     VERSION
# gem "actionmailer",  VERSION
# gem "railties",      VERSION

gem 'pg', "~> 1.0", platforms: [:ruby, :mingw]
#gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby
gem 'resque'

# Deployment
#gem 'unicorn', require: false, platforms: :ruby
gem "puma"
gem 'dotenv-rails'
gem 'bootsnap', require: false

# Secure password
gem 'bcrypt', '~> 3.1.7'

# Translations
gem 'rails-i18n'

# Old rails functionality
gem "actionpack-page_caching", "~> 1.1"
gem "rails-controller-testing"

# AR utils
gem 'ancestry', ">= 3.0.2"
gem "acts_as_list"

# Templating
gem "haml"
gem 'haml-rails'
gem 'haml-contrib'
gem 'RedCloth'
gem 'rinku'

# Improved functionality utils
gem 'kaminari'
gem 'simple_form', "~> 4.0"
gem "high_voltage"

# External services
gem 'flickraw', '~> 0.9.7'
gem 'livejournal', git: "https://github.com/khustochka/livejournal.git", branch: "alt-server"

# Small utils
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'

# Monitoring
gem 'airbrake'
gem 'newrelic_rpm'

# Assets
gem 'webpacker', '~> 3.5.2'
gem "sprockets-rails"
gem 'jquery-rails'
gem 'pjax_rails', git: "https://github.com/khustochka/pjax_rails.git", branch: "trailing-ampersand-fix"
#gem 'respond-js-rails'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails'
gem 'font-awesome-sass', "~> 4.7.0"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.3.0'

# HTTP client
gem "mechanize"

group :development do
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
  gem 'benchmark-ips'
  gem "foreman"
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end


group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  # in dev group for generators
  gem 'factory_bot_rails'
end

group :test do
  gem 'capybara', '~> 2.18'
  # This is a driver for headless JS tests (default).
  gem 'capybara-webkit', "~> 1.14"
  # And this one is if you want to see it in a real browser.
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
#  gem 'database_cleaner', '~> 1.3.0', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

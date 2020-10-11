# frozen_string_literal: true
source 'https://rubygems.org/'

if ENV['CUSTOM_RUBY_VERSION']
  ruby ENV['CUSTOM_RUBY_VERSION']
end

VERSION = "6.0.0"
#gem 'rails', VERSION
gem 'rails', git: "https://github.com/rails/rails.git", ref: "f88df82a87b93aaf1fdebadcbf93e08736492891"
# gem "activesupport", VERSION
# gem "actionpack",    VERSION
# gem "actionview",    VERSION
# gem "activemodel",   VERSION
# gem "activerecord",  VERSION
# gem "activejob",     VERSION
# gem "actionmailer",  VERSION
# gem "railties",      VERSION

gem 'pg', "~> 1.0", platforms: [:ruby, :mingw]
gem "redis"
gem "hiredis"
gem "resque"

# Deployment
gem "puma"
gem 'dotenv-rails', '~> 2.7'
# Intentionally disabled in production
#gem 'bootsnap', require: false

# Secure password
gem 'bcrypt', '~> 3.1.7'

# Translations
gem 'rails-i18n'

# Old rails functionality
gem "actionpack-page_caching"
gem "rails-controller-testing"

# AR utils
gem 'ancestry', ">= 3.2.1"
gem "acts_as_list"

# Templating
gem "haml"
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
gem 'livejournal', git: "https://github.com/khustochka/livejournal.git", branch: "further-fixes"
gem "aws-sdk-s3", require: false

# Small utils
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'

# Monitoring
gem 'airbrake'

# Image processing
gem "image_processing"

# Assets
gem 'webpacker', '~> 5.0'
gem "sprockets-rails", "~> 3.2", ">= 3.2.2"
gem 'coffee-rails'
gem 'jquery-rails'
#gem 'respond-js-rails'
gem 'sassc-rails'
gem 'font-awesome-sass', "~> 5.8"
gem "premailer-rails"
gem 'bootstrap', '~> 4.5'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.3.0'

# HTTP client
gem "mechanize"

# Profiling
gem 'rack-mini-profiler'

# Deflicker
gem "mongoid"
gem "kaminari-mongoid"

group :development do
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
  gem 'benchmark-ips'
  #gem "bundler-audit", require: false
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem "letter_opener"
  gem "letter_opener_web"
end


group :development, :test do
  gem 'bootsnap', require: false
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  # in dev group for generators
  gem 'factory_bot_rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-webkit', git: "https://github.com/thoughtbot/capybara-webkit.git", ref: "77fdac424cd6fdb5aa266b229a888cc58da8e95e"
  #gem 'webdrivers'
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
  gem 'minitest-reporters'
  gem 'simplecov-teamcity-summary'
end

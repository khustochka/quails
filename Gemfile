# frozen_string_literal: true

source "https://rubygems.org/"

ruby ">= 2.7"

VERSION = "7.0.4"
# gem "rails", VERSION
gem "activemodel",   VERSION
gem "activejob",     VERSION
gem "activerecord",  VERSION
gem "activestorage", VERSION
gem "activesupport", VERSION
gem "actionpack",    VERSION
gem "actionmailer",  VERSION
gem "actionview",    VERSION
gem "actioncable",   VERSION
gem "railties",      VERSION

gem "pg", "~> 1.0", platforms: [:ruby, :mingw]
gem "redis"
gem "hiredis"
gem "hiredis-client"
gem "resque"

# Deployment
gem "puma", "< 7"
gem "dotenv-rails", "~> 2.7"
# For puma systemd integration
gem "sd_notify"

# Secure password
gem "bcrypt", "~> 3.1.7"

# Translations
gem "rails-i18n"

# Old rails functionality
gem "actionpack-page_caching"
gem "rails-controller-testing"

# AR utils
gem "ancestry", ">= 3.2.1"
gem "acts_as_list"

# Templating
gem "haml", "< 6"
gem "haml-rails"
gem "haml-contrib"
gem "RedCloth"
gem "rinku"

# Parsing html
gem "nokogiri"

# Improved functionality utils
gem "kaminari"
gem "simple_form"
gem "high_voltage"
gem "health_check", git: "https://github.com/PCPS/health_check.git", ref: "32751bce81d48f983155f540e92806ef5c125e3f"

# External services
gem "flickraw", "~> 0.9.7"
gem "livejournal2"
gem "aws-sdk-s3"
# Enable if you need to use SES for email delivery.
# gem "aws-sdk-rails"

# Small utils
gem "addressable", require: "addressable/uri"
gem "roman-numerals"

# Monitoring
gem "airbrake"
gem "lograge"

# Image processing
gem "image_processing"

# Assets
gem "shakapacker", "6.5.4"
gem "sprockets-rails", "~> 3.2", ">= 3.2.2"
gem "jquery-rails"
gem "sassc-rails"
gem "premailer-rails"

# gem "uglifier", ">= 1.3.0"

# HTTP client
gem "mechanize"

# Profiling
gem "rack-mini-profiler", require: false # false is required to be able to disable

# Deflicker
gem "mongoid"
gem "kaminari-mongoid"

# Fixes
# rexml is a bundled gem since ruby 3.0. This means it is not available by default.
# The following gems depend on it, but do not yet require is as a dependency:
# aws-sdk-core, coderay (?), letter_opener_web, livejournal2, selenium-webdriver
gem "rexml"

group :development do
  gem "listen" # required for tracking file changes in development
  gem "benchmark-ips"
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "bundler-audit", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rake", require: false
end

group :development, :test do
  gem "debug", ">= 1.0.0"
  # in dev group for generators
  gem "factory_bot_rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
  gem "launchy" # So you can do Then show me the page
  gem "simplecov", require: false, platforms: [:ruby, :mingw]
  gem "minitest-reporters"
  gem "simplecov-teamcity-summary"
end

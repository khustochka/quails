# frozen_string_literal: true

source "https://gem.coop"

ruby ">= 3.0"

VERSION = "8.0.3"
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

gem "pg"
gem "redis"
gem "hiredis-client"
gem "rails-brotli-cache"
gem "brotli"
gem "good_job", "~> 4.0"

# Deployment
gem "puma", "< 8"
gem "dotenv", "~> 3.0"
# For puma systemd integration
# gem "sd_notify"

# Secure password
gem "bcrypt", "~> 3.1.7"

# Translations
gem "rails-i18n"

# Old rails functionality
gem "actionpack-page_caching"

# AR utils
gem "ancestry", ">= 3.2.1"
gem "acts_as_list"

# Templating
gem "haml", "~> 6.2"
gem "haml-rails", "~> 3.0"
gem "RedCloth", git: "https://github.com/moneybird/redcloth.git", ref: "ae8d6a91826734ad0a24dfed649e4c6c05283a59"
gem "rinku"

# Parsing html
gem "nokogiri"

# Improved functionality utils
gem "kaminari"
gem "simple_form"
gem "high_voltage"
gem "health_check_rb", git: "https://github.com/khustochka/health_check_rb.git", ref: "773d63ac66563247ec623031eb9139f23b76ffdc"

# External services
gem "flickraw-cached"
gem "livejournal2"
gem "aws-sdk-s3"
# Enable if you need to use SES for email delivery.
# gem "aws-sdk-rails"

# Small utils
gem "addressable", require: "addressable/uri"
gem "roman-numerals"
gem "stringio", "~> 3.1.2"
gem "uri"
gem "csv"

# Monitoring
gem "datadog", require: false
gem "honeybadger", "~> 6.0"
gem "lograge"
# gem "airbrake"

# Image processing
gem "image_processing"

# Assets
gem "jsbundling-rails"
gem "sprockets-rails", "~> 3.2", ">= 3.2.2"
gem "jquery-rails"
gem "sassc-rails"
gem "premailer-rails"
gem "font-awesome-sass", "~> 6.7.2"

# gem "uglifier", ">= 1.3.0"

# HTTP client
gem "mechanize"

# Profiling
gem "rack-mini-profiler", require: false # false is required to be able to disable

# Fixes:
# rexml is a bundled gem since ruby 3.0. This means it is not available by default.
# The following gems depend on it, but do not yet require is as a dependency:
# aws-sdk-core, livejournal2
gem "rexml"

# Bundle some default gems to use newer versions.
gem "psych"
gem "ostruct"
gem "base64"

# drb references observer but does not list it as a dependency.
gem "drb"
gem "observer"

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
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
end

group :development, :test do
  gem "debug", ">= 1.0.0"
  # in dev group for generators
  gem "factory_bot_rails"
  gem "rails-controller-testing"
end

group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "webmock"
  gem "launchy" # So you can do Then show me the page
  gem "simplecov", require: false
  gem "minitest-reporters"
  gem "simplecov-teamcity-summary"
end

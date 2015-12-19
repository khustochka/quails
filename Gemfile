source 'https://rubygems.org/'

ruby '2.2.3'

gem 'rails', '4.2.5'

gem 'pg', platforms: [:ruby, :mingw]
gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

gem 'unicorn', require: false, platforms: :ruby

group :production do
  gem 'airbrake', '~> 4.3.4'
end

# Bundle the extra gems:
gem 'actionpack-page_caching'
#gem 'dalli'
gem 'rails-i18n'
gem "haml", "~> 4.0.4"
gem 'haml-rails'
gem 'haml-contrib'
gem 'RedCloth'
gem 'kaminari'
gem 'simple_form'
gem 'flickraw', '~> 0.9.7'
gem 'livejournal', '~> 0.3.9'
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'
gem 'rinku'
gem 'dotenv-rails'
gem 'ancestry'
gem 'ordered-active-record'

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
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', groups: [:development, :test]

group :test do
  gem 'capybara'
  gem 'capybara-webkit'#, '~> 1.2.0', platforms: [:mri], require: false
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
#  gem 'database_cleaner', '~> 1.3.0', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

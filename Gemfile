source 'https://rubygems.org/'

ruby '2.1.0'

gem 'rails', '4.0.2'

gem 'pg', platforms: [:ruby, :mingw]
gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

gem 'unicorn', '~> 4.8.0', require: false, platforms: :ruby

group :production do
  gem 'airbrake'
end

# Bundle the extra gems:
gem 'actionpack-page_caching'
#gem 'dalli'
gem 'rails-i18n'
gem "haml", "~> 4.0.4"
gem 'haml-rails', '~> 0.5.1'
gem 'haml-contrib'
gem 'RedCloth'
gem 'kaminari'
gem 'simple_form', '~> 3.0.0'
gem 'flickraw', '~> 0.9.7'
gem 'vk_livejournal'
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'
gem 'rinku'
gem 'dotenv-rails'

gem 'sass-rails', '~> 4.0.0'
#gem 'coffee-rails', '~> 4.0.0'
#gem 'turbo-sprockets-rails3'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.0.3'

# For heroku
gem 'rails_stdout_logging', require: false

group :development do
  gem 'rails3-generators'
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
end

group :development, :vps do
  gem 'grit', '~> 2.5', require: false, platforms: [:ruby, :mingw]
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', groups: [:development, :test]

group :test do
  gem 'minitest-reporters'
  gem 'capybara', '~> 2.2.0'
  gem 'capybara-webkit', '~> 1.0',platforms: [:mri], require: false
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
  gem 'database_cleaner', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

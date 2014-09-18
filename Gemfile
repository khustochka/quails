source 'https://rubygems.org/'

ruby '2.1.2'

gem 'rails', github: 'rails/rails'
gem 'rails-dom-testing', github: 'rails/rails-dom-testing'

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
gem 'simple_form', github: 'plataformatec/simple_form', branch: 'rails-4-2'
gem 'flickraw', '~> 0.9.7'
gem 'livejournal', '~> 0.3.9'
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'
gem 'rinku'
gem 'dotenv-rails'
gem 'ancestry'
gem 'ordered-active-record'

gem 'sass-rails', '5.0.0.beta1'
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes

gem 'uglifier', '>= 1.0.3'

# For heroku
gem 'rails_stdout_logging', require: false

group :development do
  gem 'nokogiri', platforms: [:ruby, :mingw], require: false
  gem 'pry-rails'
end

# in dev group for generators
gem 'factory_girl_rails', '~> 4.0', groups: [:development, :test]

group :test do
  gem 'capybara'
  gem 'capybara-webkit', '~> 1.0', platforms: [:mri], require: false
  gem 'selenium-webdriver'
#  gem 'poltergeist', platforms: [:mri], require: false
  gem 'database_cleaner', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

source 'https://rubygems.org/'

ruby '2.0.0'

gem 'rails', '3.2.13'
# gem 'rails', github: 'rails/rails'

gem 'pg', platforms: [:ruby, :mingw]
gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

gem 'unicorn', require: false, platforms: :ruby

# Bundle the extra gems:
gem 'rails-i18n'
gem 'haml-rails', '~> 0.4'
gem 'haml-contrib'
gem 'RedCloth'
gem 'kaminari'
#gem 'rails_autolink'
gem 'simple_form', '~> 2.0'
gem 'flickraw', '~> 0.9.5', require: false
gem 'flickraw-cached'
gem 'livejournal'
gem 'hashie'
gem 'roman-numerals'

group :production do
  gem 'airbrake'
  gem 'newrelic_rpm'
end

gem 'sprockets', '2.2.2.backport1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'
  gem 'turbo-sprockets-rails3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes

  gem 'uglifier', '>= 1.0.3'
end

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
  gem 'test-unit'
  gem 'capybara', '~> 2.0'
  gem 'capybara-webkit', platforms: [:mri], require: false
  gem 'poltergeist', platforms: [:mri], require: false
  gem 'database_cleaner', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

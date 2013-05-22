source 'https://rubygems.org/'

ruby '2.0.0'

#gem 'rails', '4.0.0.rc1'
gem 'rails', github: 'rails/rails', branch: '4-0-0'

gem 'pg', platforms: [:ruby, :mingw]
gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

gem 'unicorn', require: false, platforms: :ruby

group :production do
  gem 'airbrake'
  gem 'newrelic_rpm'
end

# Bundle the extra gems:
gem 'actionpack-page_caching'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rails-i18n'
gem 'haml-rails', github: 'indirect/haml-rails'
gem 'haml-contrib'
gem "haml"
gem 'RedCloth'
gem 'kaminari'
#gem 'rails_autolink'
gem 'simple_form', '~> 3.0.0.rc'
gem 'flickraw', '~> 0.9.5', require: false
gem 'flickraw-cached'
gem 'livejournal'
gem 'hashie'
gem 'addressable', require: 'addressable/uri'
gem 'roman-numerals'
gem 'rinku'

gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'

  gem 'sass-rails', '~> 4.0.0.rc1'
  #gem 'coffee-rails', '~> 3.2.1'
  #gem 'turbo-sprockets-rails3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes

  gem 'uglifier', '>= 1.0.3'

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
  gem 'ruby-prof', require: false, platforms: [:mri, :mingw]
  gem 'capybara', '~> 2.1.0'
  gem 'capybara-webkit', '~> 1.0',platforms: [:mri], require: false
  gem 'poltergeist', platforms: [:mri], require: false
  gem 'database_cleaner', require: false
  gem 'launchy' # So you can do Then show me the page
  gem 'simplecov', require: false, platforms: [:ruby, :mingw]
end

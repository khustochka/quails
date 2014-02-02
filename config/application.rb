require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Quails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/app/presenters)
    config.autoload_paths += %W(#{config.root}/app/controllers/mixins #{config.root}/app/models/formatters)

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.template_engine :haml
      g.fixture_replacement :factory_girl
    end

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types.
    # config.active_record.schema_format = :sql

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Kyiv'
    # THIS APP SPECIFIC NOTE: if you ever have to change the time zone take into account that 'posts.facedate'
    # is not a timezone dependent timestamp but rather a carved in stone time and should be shown the same to everyone
    # so you'll have to convert it in the DB

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '{en,ru,uk}','*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru

    # Maybe this is not necessary (or for Windows?)
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

  end
end

require 'quails/env'

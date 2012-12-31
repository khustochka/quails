require File.expand_path('../boot', __FILE__)


require 'rails/all'


# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

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
      g.template_engine :haml, form_builder: :simple_form
      g.fixture_replacement :factory_girl
    end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types.
    # config.active_record.schema_format = :sql


    # Enable the asset pipeline.
    config.assets.enabled = true

    # Prevent running initializers on precompile
    # (required for heroku, and works only in application.rb, not in production.rb)
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets.
    config.assets.version = '1.0'

  end
end

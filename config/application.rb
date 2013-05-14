require File.expand_path('../boot', __FILE__)


require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

#FIXME: see https://github.com/rails/rails-observers/issues/4
require 'rails/observers/activerecord/base'
require 'rails/observers/activerecord/observer'

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

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types.
    # config.active_record.schema_format = :sql

    # FIXME: does not work in rails 4 ?
    # Prevent running initializers on precompile
    # (required for heroku, and works only in application.rb, not in production.rb)
    config.assets.initialize_on_precompile = false

  end
end

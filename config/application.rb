# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Quails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.template_engine :haml
      g.fixture_replacement :factory_bot
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

    # Will I need this prefixing at some point?
    config.action_view.prefix_partial_path_with_controller_namespace = false

    require 'core_ext/active_storage/exif_date_image_analyzer'
    config.active_storage.analyzers = [ActiveStorage::Analyzer::ExifDateImageAnalyzer]
    config.active_storage.track_variants = true
  end
end

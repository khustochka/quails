# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Enable static file serving from the `/public` folder (turn off if using NGINX/Apache for it).
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service =
    if Quails.env.live? || ENV["PROD_S3"]
      :amazon
    elsif ENV["DEV_S3"]
      :amazon_dev
    else
      :local
    end

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = Quails.env.ssl?

  # If we want the browsers to forget HSTS setting
  if Quails.env.no_hsts?
    config.ssl_options = { hsts: false }
  end

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new($stdout)
    .tap  { |logger| logger.formatter = Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Info include generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  config.cache_store = RailsBrotliCache::Store.new(
    ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_CACHE_URL"])
  )

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :good_job
  # config.active_job.queue_name_prefix = "quails_#{Quails.env.live? ? "LIVE" : Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = false

  # Don't log any deprecations.
  # config.active_support.report_deprecations = false

  config.active_support.deprecation = :log

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  allowed_hostnames = ENV["ALLOWED_HOSTNAMES"].yield_self do |str|
    str.present? ? str.split(",") : []
  end

  if allowed_hostnames.any?
    config.hosts += allowed_hostnames
  elsif Quails.env.live?
    config.hosts << "birdwatch.org.ua"
  end
  config.host_authorization = {
    exclude: ->(request) { request.path.include?("/health_check") },
    response_app: ->(_) { [403, {}, ["Incorrect host name"]] },
  }

  # Route error pages through custom middleware
  require "quails/public_exceptions"
  config.exceptions_app = Quails::PublicExceptions.new(Rails.public_path)

  # Alternative location for page caching
  # App user should be able to write to this location, but we do not want it to write to 'public'
  # FIXME: files from this folder are not served by Rails. Nginx not yet setup to serve static files.
  # And /public is not writable.
  config.action_controller.page_cache_directory = Rails.root.join("tmp/cached_pages")
  # This does not work:
  # config.paths["public"] << "tmp/cached_pages"
end

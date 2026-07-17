# frozen_string_literal: true

# Required to prevent vips issues on MacOS
# See https://github.com/libvips/ruby-vips/issues/155
require "vips"

# Rails is not loaded yet here, so ActiveSupport's `in?` or `present?` is not available.
if %w(true 1).include?(ENV["COVERAGE"])
  require "simplecov"
  SimpleCov.start "rails" do
    # Excluded from the report so the percentage reflects code we intend to test:
    # obsolete analytics, and code that cannot be exercised without a third-party service.
    skip "app/helpers/shynet_helper.rb"
    skip "app/helpers/google_analytics_helper.rb"
    skip "app/models/ioc_taxon.rb"
    skip "app/models/flickr_upload.rb"
    skip "app/controllers/content_security_controller.rb"
    skip "app/controllers/ebird/alerts_controller.rb"
    skip "app/controllers/flickr_controller.rb"

    # Jobs that only do eBird/Flickr round trips.
    skip "app/jobs/ebird/alert_preload_job.rb"
    skip "app/jobs/ebird/alert_refresh_all_job.rb"
    skip "app/jobs/ebird/checklist_fix_job.rb"
    skip "app/jobs/ebird/checklist_import_job.rb"
    skip "app/jobs/flickr_to_storage_job.rb"
    skip "app/jobs/flickr_upload_job.rb"

    if ENV["TEAMCITY_VERSION"]
      at_exit do
        SimpleCov::Formatter::TeamcitySummaryFormatter.new.format(SimpleCov.result)
        # SimpleCov.result.format! # uncomment for additional detailed HTML report for TeamCity artifacts
      end
    end
  end
  # When running with COVERAGE=true consider also setting CI=true to eager load the code.
  # if spring is used app needs to be preloaded - also may need to be moved after File.expand_path('../../config/environment', __FILE__)
  # see https://github.com/colszowka/simplecov/issues/381#issuecomment-435356201
  # Rails.application.eager_load!
end

ENV["RAILS_ENV"] ||= "test"
ENV["SE_AVOID_STATS"] = "true" # Disable Chromedriver telemetry (probably not working)
# https://github.com/SeleniumHQ/selenium/pull/13173

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "webmock/minitest"

unless ENV["RM_INFO"]
  require "minitest/reporters"
  Minitest::Reporters.use!
end

Capybara.server = :puma, { Silent: true }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors, threshold: 30)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include FactoryBot::Syntax::Methods

    delegate :url_for, to: :@controller

    def login_as_admin
      @request.session[:admin] = true
    end

    def with_direct_variant_urls
      ENV["QUAILS_DIRECT_VARIANT_URLS"] = "true"
      # Required by the Disk service to generate direct urls outside a request
      ActiveStorage::Current.url_options ||= { host: "www.example.com" }
      yield
    ensure
      ENV.delete("QUAILS_DIRECT_VARIANT_URLS")
    end

    # current path that preserves arguments after ? and # (unlike current_path)
    def current_path_info
      current_url.sub(%r{.*?://}, "")[%r{[/\?\#].*}] || "/"
    end

    # Reset locale to default. (There was a rarely happening failure caused by incorrect path was accessed because of
    # English locale leaking - probably due to multi-threading?)
    setup do
      I18n.locale = I18n.default_locale # rubocop:disable Rails/I18nLocaleAssignment
    end
  end
end

# frozen_string_literal: true

if ENV["COVERAGE"].present?
  require "simplecov"
  SimpleCov.start "rails" do
    if ENV["TEAMCITY_VERSION"]
      at_exit do
        SimpleCov::Formatter::TeamcitySummaryFormatter.new.format(SimpleCov.result)
        # SimpleCov.result.format! # uncomment for additional detailed HTML report for TeamCity artifacts
      end
    end
  end
  # if spring is used app needs to be preloaded - also may need to be moved after File.expand_path('../../config/environment', __FILE__)
  # see https://github.com/colszowka/simplecov/issues/381#issuecomment-435356201
  # Rails.application.eager_load!
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

unless ENV["RM_INFO"]
  require "minitest/reporters"
  MiniTest::Reporters.use!
end

Capybara.server = :puma, { Silent: true }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: ENV["COVERAGE"] ? 1 : :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include FactoryBot::Syntax::Methods

    delegate :url_for, to: :@controller

    def login_as_admin
      @request.session[:admin] = true
    end

    # current path that preserves arguments after ? and # (unlike current_path)
    def current_path_info
      current_url.sub(%r{.*?://}, "")[%r{[/\?\#].*}] || "/"
    end

    # Reset locale to default. (There was a rarely happening failure caused by incorrect path was accessed because of
    # English locale leaking - probably due to multi-threading?)
    setup do
      # rubocop:disable Rails/I18nLocaleAssignment
      I18n.locale = I18n.default_locale
    end
  end
end

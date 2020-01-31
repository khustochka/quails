if ENV['COVERAGE'] == 'true'
  begin
    require 'simplecov'
    SimpleCov.start 'rails' do
      if ENV['TEAMCITY_VERSION']
        at_exit do
          SimpleCov::Formatter::TeamcitySummaryFormatter.new.format(SimpleCov.result)
          # SimpleCov.result.format! # uncomment for additional detailed HTML report for TeamCity artifacts
        end
      end
    end
    Rails.application.eager_load!
  rescue LoadError, RuntimeError
  end
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

unless ENV["RM_INFO"]
  require 'minitest/reporters'
  MiniTest::Reporters.use!
end

class ActiveSupport::TestCase

  parallelize(workers: ENV["COVERAGE"] ? 1 : 4)

  fixtures :all

  include FactoryBot::Syntax::Methods

  delegate :url_for, to: :@controller

  def login_as_admin
    @request.session[:admin] = true
  end

  # current path that preserves arguments after ? and # (unlike current_path)
  def current_path_info
    current_url.sub(%r{.*?://}, '')[%r{[/\?\#].*}] || '/'
  end

  # Reset locale to default. (There was a rarely happening failure caused by incorrect path was accessed because of
  # English locale leaking - probably due to multi-threading?)
  setup do
    I18n.locale = I18n.default_locale
  end

end

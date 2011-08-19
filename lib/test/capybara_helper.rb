require 'capybara/rails'

module CapybaraTestCase
  include Capybara::DSL

  def self.included(klass)
    klass.teardown do
      Capybara.reset_sessions!
    end
  end

  def login_as_admin
    if page.driver.try(:browser).respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(ActiveSupport::TestCase::TEST_CREDENTIALS.username, ActiveSupport::TestCase::TEST_CREDENTIALS.password_plain)
      # To set cookies
      visit '/login'
    else
      # FIXME for this to work you need to add pref("network.http.phishy-userpass-length", 255); to /Applications/Firefox.app/Contents/MacOS/defaults/pref/firefox.js
      str = "http://%s:%s@%s:%s/login"
      visit str % [TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain, page.driver.rack_server.host, page.driver.rack_server.port]
    end
  end
end

module JavaScriptTestCase

  def self.included(klass)
    klass.include CapybaraTestCase

    klass.setup do
      Capybara.current_driver = Capybara.javascript_driver
    end

    klass.teardown do
      Capybara.use_default_driver
    end

  end
end
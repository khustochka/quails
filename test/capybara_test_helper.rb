require "test_helper"
require 'capybara/rails'

class CapybaraTestCase < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def login_as_admin
    if page.driver.try(:browser).respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain)
      # To set cookies
      visit '/login'
    else
    # FIXME for this to work you need to add pref("network.http.phishy-userpass-length", 255); to /Applications/Firefox.app/Contents/MacOS/defaults/pref/firefox.js
    str = "http://%s:%s@%s:%s/login"
    visit str % [TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain, page.driver.rack_server.host, page.driver.rack_server.port]
    end
  end
end

class JavaScriptTestCase < CapybaraTestCase
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    Capybara.use_default_driver
  end
end
require "test_helper"

module QuailsTestCase
  class CapybaraTestCase < ActionDispatch::IntegrationTest
    require 'capybara/rails'
    include Capybara::DSL

    def login_as_admin
      if page.driver.respond_to?(:basic_auth)
        page.driver.basic_auth(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain)
      elsif page.driver.respond_to?(:basic_authorize)
        page.driver.basic_authorize(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain)
      elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
        page.driver.browser.basic_authorize(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain)
      else
        # FIXME for this to work you need to add pref("network.http.phishy-userpass-length", 255); to /Applications/Firefox.app/Contents/MacOS/defaults/pref/firefox.js
        page.driver.visit('/')
        page.driver.visit("http://#{TEST_CREDENTIALS.username}:#{TEST_CREDENTIALS.password_plain}@#{page.driver.current_url.gsub(/^http\:\/\//, '')}/dashboard")
      end

      # To set cookies
      visit '/dashboard'
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
end
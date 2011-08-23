require 'capybara/rails'

module CapybaraTestCase
  include Capybara::DSL

  def self.included(klass)
    klass.teardown do
      Capybara.reset_sessions!
    end
  end

  def login_as_admin
    test_credentials = ActiveSupport::TestCase::TEST_CREDENTIALS
    if page.driver.try(:browser).respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(test_credentials.username, test_credentials.password_plain)
      # To set cookies
      visit '/login'
    else
      # FIXME for this to work you need to add pref("network.http.phishy-userpass-length", 255); to /Applications/Firefox.app/Contents/MacOS/defaults/pref/firefox.js
      str = "http://%s:%s@%s:%s/login"
      visit str % [test_credentials.username, test_credentials.password_plain, page.driver.rack_server.host, page.driver.rack_server.port]
    end
  end
end

module JavaScriptTestCase

  def self.included(klass)
    klass.class_eval do
      include CapybaraTestCase

      setup do
        Capybara.current_driver = Capybara.javascript_driver
      end

      teardown do
        Capybara.use_default_driver
      end

      def select_suggestion(value, hash)
        selector = ".ui-menu-item a:contains(\"#{value}\"):first"
        fill_in hash[:from], :with => value
        #sleep(0.5)
        page.execute_script " $('#{selector}').trigger('mouseenter').click();"
      end
    end

  end
end
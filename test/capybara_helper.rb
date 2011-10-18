require 'capybara/rails'

# To enable transactions (i.e. proper teardown) for tests run via selenium
# https://groups.google.com/forum/#!msg/ruby-capybara/JI6JrirL9gM/R6YiXj4gi_UJ
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

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
      page.driver.browser.basic_authorize(test_credentials.username, test_credentials.password)
      # To set cookies
      # visit '/login'
    else
      # FIXME for this to work you need to add pref("network.http.phishy-userpass-length", 255); to /Applications/Firefox.app/Contents/MacOS/defaults/pref/firefox.js
      str = "http://%s:%s@%s:%s/login"
      visit str % [test_credentials.username, test_credentials.password, page.driver.rack_server.host, page.driver.rack_server.port]
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
  
      alias_method :native_click_button, :click_button
      def click_button(button)
        native_click_button(button)
        sleep 0.5
      end
    end

  end
end
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara_drivers'

#Capybara.default_wait_time = 5

# Seems like all the commented out stuff below is NOT VALID since Rails 5.1

# There are problems with transactional fixtures in Selenium tests, because
# Capybara uses a separate server thread.
# BUT: I found out that we do not need DatabaseCleaner etc, we just need to run factories
# before opening the browser (using visit or login_as_admin)

# To enable FactoryBot (and probably transactions) for tests run via selenium
# https://groups.google.com/forum/#!msg/ruby-capybara/JI6JrirL9gM/R6YiXj4gi_UJ
# class ActiveRecord::Base
#   mattr_accessor :shared_connection
#   @@shared_connection = nil
#
#   def self.connection
#     @@shared_connection || retrieve_connection
#   end
# end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
#ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

module CapybaraTestCase
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  TEST_CREDENTIALS = {username: ENV['admin_username'], password: ENV['admin_password']}

  def self.included(klass)

    klass.teardown do
      Capybara.reset_sessions!
    end
  end

  def login_as_admin
    visit '/login'
    fill_in 'username', with: TEST_CREDENTIALS[:username]
    fill_in 'password', with: TEST_CREDENTIALS[:password]
    click_button "Login"
  end
end

module JavaScriptTestCase
  def self.included(klass)
    klass.class_eval do
      include CapybaraTestCase

      # We potentially can use this instead of setup/teardown
      # but is slightly slower and also messes with UI_ tests
      # driven_by :webkit

      setup do
        Capybara.current_driver = ENV['JS_DRIVER'].try(:to_sym) || Capybara.javascript_driver
      end

      teardown do
        Capybara.use_default_driver
      end

      def select_suggestion(value, hash)
        selector = ".ui-menu-item a:contains(\"#{value}\"):first"
        fill_in hash[:from], with: value
        sleep(0.05)
        #raise "No element '#{value}' in the field #{hash[:from]}" unless page.has_selector?(:xpath, "//*[@class=\"ui-menu-item\"]//a[contains(text(), \"#{value}\")]")
        page.execute_script " $('#{selector}').trigger('mouseenter').click();"
      end

      # This is required for clicking font-awesome icon links (like .remove)
      def click_icon_link(selector)
        find(:css, selector).click
      end

      # Standard capybara attach_file make_visible option does not work for me
      def with_element_visible(jquery_selector)
        page.execute_script "$('#{jquery_selector}').show();"
        yield
        page.execute_script "$('#{jquery_selector}').hide();"
      end

    end

  end
end

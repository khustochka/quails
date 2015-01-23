require 'capybara/rails'
require 'seed_helper'
require 'capybara_drivers'

#Capybara.default_wait_time = 5

# There are problems with transactional fixtures in Selenium tests, because
# Capybara uses a separate server thread.
# BUT: I found out that we do not need DatabaseCleaner etc, we just need to run factories
# before opening the browser (using visit or login_as_admin)
# TODO: override factory's create method to check if browser is open!

# To enable FactoryGirl (and probably transactions) for tests run via selenium
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

      setup do
        Capybara.current_driver = ENV['JS_DRIVER'].try(:to_sym) || Capybara.javascript_driver
        page.driver.allow_url("data:image/*")
        page.driver.block_unknown_urls
      end

      teardown do
        Capybara.use_default_driver
      end

      def select_suggestion(value, hash)
        selector = ".ui-menu-item a:contains(\"#{value}\"):first"
        fill_in hash[:from], with: value
        sleep(0.01)
        page.execute_script " $('#{selector}').trigger('mouseenter').click();"
      end

      def accept_modal_dialog
        if page.driver.browser.respond_to? :switch_to
          page.driver.browser.switch_to.alert.accept
        end
      end

    end

  end
end

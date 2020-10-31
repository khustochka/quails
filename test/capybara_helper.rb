# frozen_string_literal: true

require "capybara/rails"
require "capybara/minitest"

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

  TEST_CREDENTIALS = {username: ENV["admin_username"], password: ENV["admin_password"]}

  def self.included(klass)
    klass.teardown do
      Capybara.reset_sessions!
    end
  end

  def login_as_admin
    visit "/login"
    fill_in "username", with: TEST_CREDENTIALS[:username]
    fill_in "password", with: TEST_CREDENTIALS[:password]
    click_button "Login"
  end
end

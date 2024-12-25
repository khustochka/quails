# frozen_string_literal: true

require "test_helper"

WebMock.disable_net_connect!(allow_localhost: true)

# Playwright: https://justin.searls.co/posts/running-rails-system-tests-with-playwright-instead-of-selenium/
# To install: yarn run playwright install

default_driver = :playwright
$js_driver = ENV["JS_DRIVER"]&.to_sym || default_driver

# Browsers are: chromium, firefox, webkit
$js_browser = ENV["JS_BROWSER"]&.to_sym || :chromium

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: $js_browser,
    headless: !ENV["NOT_HEADLESS"]
  )
end

puts("Using driver: #{$js_driver}" + ($js_browser ? ", browser: #{$js_browser}" : ""))

# Selenium::WebDriver.logger.info("Using driver: #{$js_driver}" + ($js_browser ? ", browser: #{$js_browser}" : ""))

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by $js_driver

  # Suppress deprecation message of :capabilities parameter
  # Selenium::WebDriver.logger(ignored: :capabilities)

  TEST_CREDENTIALS = { username: ENV["QUAILS_ADMIN_USERNAME"], password: ENV["QUAILS_ADMIN_PASSWORD"] }

  # FIXME: try to fix those errors
  IGNORED_JS_ERRORS = [
    "Failed to load resource: net::ERR_CONNECTION_REFUSED",
    "Failed to load resource: net::ERR_INTERNET_DISCONNECTED",
    "The source list for the Content Security Policy directive 'script-src' contains an invalid source: ''nonce-''. It will be ignored.",
  ]

  def login_as_admin
    visit "/login"
    fill_in "username", with: TEST_CREDENTIALS[:username]
    fill_in "password", with: TEST_CREDENTIALS[:password]
    click_button "Login"
  end

  def select_suggestion(value, hash)
    selector = ".ui-menu-item a:contains(\"#{value}\"):first"
    fill_in hash[:from], with: value
    sleep(0.5) # Chrome driver needs pretty high values
    # raise "No element '#{value}' in the field #{hash[:from]}" unless page.has_selector?(:xpath, "//*[@class=\"ui-menu-item\"]//a[contains(text(), \"#{value}\")]")
    page.execute_script " $('#{selector}').trigger('mouseenter').click();"
  end

  def click_add_new_row
    find(:xpath, "//span[text()='Add new row']").click
    sleep(0.05)
  end

  # This is required for clicking font-awesome icon links (like .remove)
  def click_icon_link(selector)
    find(:css, selector).click
  end

  def fill_in_date(field, date)
    # As a workaround for Chrome we convert the date field to text
    # Field is required to have id!
    if chrome_driver?
      f = find(:fillable_field, field)
      execute_script("$('##{f[:id]}').attr('type', 'text')")
    end
    fill_in(field, with: date)
  end

  # Standard capybara attach_file make_visible option does not work for me
  def with_element_visible(jquery_selector)
    page.execute_script "$('#{jquery_selector}').show();"
    yield
    page.execute_script "$('#{jquery_selector}').hide();"
  end

  def chrome_driver?
    $js_browser.to_s.include?("chrome")
  end

  def check_js_errors
    # browser = page.driver.browser
    # if browser.respond_to?(:logs)
    #   errors = browser.logs.get(:browser)
    #   errors.each do |error|
    #     severe_error = error.level == "SEVERE" && IGNORED_JS_ERRORS.none? {|line| error.message.include?(line)}
    #     assert_not(severe_error, error.message)
    #   end
    # end
  end

  teardown do
    check_js_errors
  end
end

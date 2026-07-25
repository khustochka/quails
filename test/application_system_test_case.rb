# frozen_string_literal: true

require "test_helper"

WebMock.disable_net_connect!(allow_localhost: true)

# Playwright: https://justin.searls.co/posts/running-rails-system-tests-with-playwright-instead-of-selenium/
# To install: yarn run playwright install

default_driver = :playwright_test
$js_driver = ENV["JS_DRIVER"]&.to_sym || default_driver

# Browsers are: chromium, firefox, webkit
$js_browser = ENV["JS_BROWSER"]&.to_sym || :chromium

# Renaming the driver is needed for the 'headless' option to work:
# https://github.com/YusukeIwaki/capybara-playwright-driver/issues/93
Capybara.register_driver :playwright_test do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: $js_browser,
    headless: !ENV["NOT_HEADLESS"]
  )
end

# Parallel workers share one Puma and one Postgres, so a form submit plus page load
# can occasionally exceed the 2s default. The driver derives Playwright's navigation
# timeout from this value, and waits end as soon as the condition holds.
Capybara.default_max_wait_time = 5

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

  # Set FAIL_ON_JS_ERRORS=1 to turn collected browser errors into test failures.
  FAIL_ON_JS_ERRORS = ENV["FAIL_ON_JS_ERRORS"].present?

  setup do
    @js_errors = []
    @allowed_js_errors = []
    collect_js_errors
  end

  # For tests that provoke browser errors on purpose (e.g. requesting a missing asset
  # to exercise a fallback). Matches as a substring.
  def allow_js_errors(*patterns)
    @allowed_js_errors.concat(patterns)
  end

  teardown do
    check_js_errors
  end

  def login_as_admin
    visit "/login"
    fill_in "username", with: TEST_CREDENTIALS[:username]
    fill_in "password", with: TEST_CREDENTIALS[:password]
    click_button "Login"
  end

  def select_suggestion(value, hash)
    fill_in hash[:from], with: value
    page.document.assert_selector(".ac-dropdown a", text: value, wait: 2)
    page.execute_script <<~JS
      const dropdown = Array.from(document.querySelectorAll('.ac-dropdown')).find(el => el.style.display !== 'none');
      Array.from(dropdown.querySelectorAll('a')).find(a => a.textContent.includes(#{value.to_json})).click();
    JS
  end

  def click_add_new_row
    prev_count = all(".obs-row").size
    find(:xpath, "//span[text()='Add new row']").click
    assert_selector ".obs-row", minimum: prev_count + 1
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
      execute_script("document.getElementById('#{f[:id]}').type = 'text'")
    end
    fill_in(field, with: date)
  end

  # Standard capybara attach_file make_visible option does not work for me
  def with_element_visible(css_selector)
    page.execute_script "document.querySelector('#{css_selector}').style.display = 'block';"
    yield
    page.execute_script "document.querySelector('#{css_selector}').style.display = 'none';"
  end

  def chrome_driver?
    $js_browser.to_s.include?("chrome")
  end

  # Attaches Playwright listeners for uncaught exceptions and console errors. Must run before
  # the first `visit`: `with_playwright_page` builds the page that the whole test then reuses.
  def collect_js_errors
    return unless page.driver.respond_to?(:with_playwright_page)

    page.driver.with_playwright_page do |pw_page|
      pw_page.on("pageerror", ->(error) { @js_errors << "#{error.name}: #{error.message}\n#{error.stack}" })
      pw_page.on("console", lambda { |message|
        @js_errors << "console.#{message.type}: #{message.text}" if message.type == "error"
      })
    end
  end

  def check_js_errors
    ignored = IGNORED_JS_ERRORS + @allowed_js_errors
    errors = @js_errors.reject { |error| ignored.any? { |line| error.match?(Regexp.escape(line)) } }
    return if errors.empty?

    report = "#{errors.size} JavaScript error(s) in #{name}:\n#{errors.join("\n---\n")}"
    FAIL_ON_JS_ERRORS ? flunk(report) : warn(report)
  end
end

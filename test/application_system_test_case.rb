# frozen_string_literal: true

require "test_helper"

begin
  require "capybara/webkit"
rescue LoadError
  puts "[NOTE] capybara-webkit not available"
end

# :selenium_chrome_headless unfortunately is slower
DEFAULT_JS_DRIVER = defined?(Capybara::Webkit) ? :webkit : :selenium_chrome_headless

env_js_driver = ENV["JS_DRIVER"]&.to_sym || DEFAULT_JS_DRIVER

puts "[NOTE] Using driver: #{env_js_driver}"

if env_js_driver =~ /\Awebkit/ && defined?(Capybara::Webkit)
  require "core_ext/capybara/webkit/node"
  Capybara::Webkit.configure do |config|
    config.block_unknown_urls
    # Don't load images
    config.skip_image_loading
    #config.raise_javascript_errors = true
  end
end

$driver, $browser = case env_js_driver
                    when /\Aselenium(?:_(.*))?/
                      [:selenium, $1 || :firefox]
                    else
                      [env_js_driver, nil]
                    end

Capybara.javascript_driver = env_js_driver || :selenium_chrome_headless

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by $driver, using: $browser, screen_size: [1400, 1400]

  # This stuff is required so that JS tests do not mess up the UI integration tests (which use rack-test)
  setup do
    Capybara.current_driver = ENV["JS_DRIVER"].try(:to_sym) || Capybara.javascript_driver
  end
  teardown do
    Capybara.use_default_driver
  end

  TEST_CREDENTIALS = {username: ENV["admin_username"], password: ENV["admin_password"]}

  def login_as_admin
    visit "/login"
    fill_in "username", with: TEST_CREDENTIALS[:username]
    fill_in "password", with: TEST_CREDENTIALS[:password]
    click_button "Login"
  end

  def select_suggestion(value, hash)
    selector = ".ui-menu-item a:contains(\"#{value}\"):first"
    fill_in hash[:from], with: value
    sleep(0.5) # Chrome driver needs pretty high values TODO: diff values for Chrome and Capy-webkit
    #raise "No element '#{value}' in the field #{hash[:from]}" unless page.has_selector?(:xpath, "//*[@class=\"ui-menu-item\"]//a[contains(text(), \"#{value}\")]")
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
    Capybara.current_driver.to_s =~ /chrome/
  end

end

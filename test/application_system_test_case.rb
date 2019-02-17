require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driver = ENV["DRIVER"]&.to_sym || :selenium
  using = ENV["USING"]&.to_sym || (driver == :selenium && :headless_chrome)

  opts =
      # if ENV["headless"]
      #   {
      #       desired_capabilities:
      #           Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: {args: ["--headless"]})
      #   }
      # else
        {}
      # end

  args = {screen_size: [1400, 1400], options: opts}
  args[:using] = using if using

  driven_by driver, args

  TEST_CREDENTIALS = {username: ENV['admin_username'], password: ENV['admin_password']}

  def login_as_admin
    visit '/login'
    fill_in 'username', with: TEST_CREDENTIALS[:username]
    fill_in 'password', with: TEST_CREDENTIALS[:password]
    click_button "Login"
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

  def fill_in_date(field, date)
    fill_in(field, with: date.sub(/(\d\d\d\d)-(\d\d)-(\d\d)/, "\\1\t\\2\\3"))
  end

  # Standard capybara attach_file make_visible option does not work for me
  def with_element_visible(jquery_selector)
    page.execute_script "$('#{jquery_selector}').show();"
    yield
    page.execute_script "$('#{jquery_selector}').hide();"
  end

end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  opts = {
      desired_capabilities:
          Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: {args: ["--headless --no-sandbox"]})
  }
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts)
end

Capybara.register_driver :ie do |app|
  Capybara::Selenium::Driver.new(app, browser: :ie, introduce_flakiness_by_ignoring_security_domains: true)
end

env_js_driver = ENV['JS_DRIVER']

def load_driver(driver)
  if !driver.to_s.in?(['chrome', "headless_chrome", 'ie'])
    require "capybara/#{driver.to_s}"
  end
  Capybara.javascript_driver = driver.to_sym
end

if env_js_driver.blank?
  begin
    load_driver(ENV["headless"] ? :headless_chrome : :chrome)
  rescue LoadError
    # Use selenium
  end
elsif env_js_driver.to_s != 'selenium'
  load_driver(env_js_driver)
end

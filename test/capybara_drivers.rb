Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :ie do |app|
  Capybara::Selenium::Driver.new(app, browser: :ie, introduce_flakiness_by_ignoring_security_domains: true)
end

env_js_driver = ENV['JS_DRIVER']

def load_driver(driver)
  require "capybara/#{driver.to_s}"
  Capybara.javascript_driver = driver.to_sym
end

if env_js_driver.blank?
  begin
    load_driver(:webkit)
  rescue LoadError
    # Use selenium
  end
else
  load_driver(env_js_driver)
end

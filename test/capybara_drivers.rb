Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :ie do |app|
  Capybara::Selenium::Driver.new(app, browser: :ie, introduce_flakiness_by_ignoring_security_domains: true)
end

if ENV['JS_DRIVER'].blank? || ENV['JS_DRIVER'].try(:to_s) == "webkit"
  begin
    require "capybara/webkit"
    Capybara.javascript_driver = :webkit
  rescue LoadError
    raise if ENV['JS_DRIVER'].try(:to_s) == "webkit"
  end
end

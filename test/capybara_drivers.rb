Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :ie do |app|
  Capybara::Selenium::Driver.new(app, browser: :ie, introduce_flakiness_by_ignoring_security_domains: true)
end

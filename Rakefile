# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Add a workaround to prevent loading development env when running system tests
# See https://github.com/rails/rails/issues/43937
if Rake.application.top_level_tasks.grep(/^(default$|test(:|$))/).any?
  ENV["RAILS_ENV"] ||= Rake.application.options.show_tasks ? "development" : "test"
end

require_relative "config/application"

Rails.application.load_tasks

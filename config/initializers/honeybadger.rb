# frozen_string_literal: true

Honeybadger.configure do |config|
  config.insights.enabled = true
  config.api_key = ENV["HONEYBADGER_API_KEY"]
  config.env = ENV["DD_ENV"] || Rails.env
end

# frozen_string_literal: true

if ENV["HONEYBADGER_API_KEY"].present?
  Honeybadger.configure do |config|
    config.insights.enabled = false
    config.api_key = ENV["HONEYBADGER_API_KEY"]
    config.env = ENV["DD_ENV"] || Rails.env
  end
end

# frozen_string_literal: true

Rails.application.configure do
  config.analytics = ENV["quails_analytics"]
end

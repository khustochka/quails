# frozen_string_literal: true

# TODO: do not load unless web
Rails.application.configure do
  config.analytics = ENV["quails_analytics"]
end

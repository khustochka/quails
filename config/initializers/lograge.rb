# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = !Rails.env.development?

  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    {
      params: event.payload[:params].yield_self {|params| params.except(*exceptions).to_json if params},
      time: Time.zone.now,
    }
  end
end

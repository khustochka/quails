Airbrake.configure do |config|
  config.project_id = true # Not needed for errbit
  config.project_key = ENV['errbit_api_key'] || "dummy"
  config.host = "https://#{ENV['errbit_host']}"
  config.environment = Rails.env
  config.ignore_environments = %w(test)
end

unless ENV['errbit_api_key'] && ENV['errbit_host']
  Airbrake.add_filter(&:ignore!)
end

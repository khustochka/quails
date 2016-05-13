if ENV['errbit_api_key'] && ENV['errbit_host']
  Airbrake.configure do |config|
    config.project_id = true # Not needed for errbit
    config.project_key = ENV['errbit_api_key']
    config.host = "https://#{ENV['errbit_host']}"
    config.environment = Rails.env
    config.ignore_environments = %w(development test)
  end
end

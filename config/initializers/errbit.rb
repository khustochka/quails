if ENV['errbit_api_key'] && ENV['errbit_host']
  Airbrake.configure do |config|
    config.project_id = "1" # Not needed for errbit
    config.project_key = ENV['errbit_api_key']
    config.host = "https://#{ENV['errbit_host']}"
    config.environment = Rails.env
    config.ignore_environments = %w(test)
  end
end

if ENV['errbit_api_key'] && ENV['errbit_host']

  Airbrake.configure do |config|
    config.project_id = "1234" # Errbit doesn't need this but Airbrake does
    config.project_key = ENV['errbit_api_key']
    config.host = "https://#{ENV['errbit_host']}"
    config.environment = Rails.env
    config.ignore_environments = [:test]
  end

end

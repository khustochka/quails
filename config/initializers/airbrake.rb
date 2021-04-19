# frozen_string_literal: true

# I recommend Errbit, which is compatible with Airbrake API, but Airbrake can be used too.
if ENV["AIRBRAKE_API_KEY"] && ENV["AIRBRAKE_HOST"]
  Airbrake.configure do |config|
    config.project_id = ENV["AIRBRAKE_PROJECT_ID"] || "1" # Not needed for errbit
    config.project_key = ENV["AIRBRAKE_API_KEY"]
    config.host = "https://#{ENV["AIRBRAKE_HOST"]}"
    config.environment = Rails.env
    config.ignore_environments = %w(test)
    # Disable monitoring not supported by Errbit
    config.job_stats = false
    config.query_stats = false
    config.performance_stats = false
    config.remote_config = false
  end
end

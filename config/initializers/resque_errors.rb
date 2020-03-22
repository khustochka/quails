if ENV['errbit_api_key'] && ENV['errbit_host']
  require 'resque/failure/multiple'
  require 'resque/failure/redis'
  require 'airbrake/resque' # use failure backend from airbrake, not from resque

  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
  Resque::Failure.backend = Resque::Failure::Multiple
end

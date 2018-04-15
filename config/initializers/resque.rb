if ENV["REDISTOGO_URL"]
  Resque.redis = Redis.new(url: ENV["REDISTOGO_URL"])
else
  Resque.redis = {:host => 'localhost', :port => 6379, :db => 0}
end

if ENV['errbit_api_key'] && ENV['errbit_host']
  require 'resque/failure/multiple'
  require 'resque/failure/redis'
  require 'airbrake/resque' # use failure backend from airbrake, not from resque
  
  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
  Resque::Failure.backend = Resque::Failure::Multiple
end

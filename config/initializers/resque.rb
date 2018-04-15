if ENV["REDISTOGO_URL"]
  Resque.redis = Redis.new(url: ENV["REDISTOGO_URL"])
else
  Resque.redis = {:host => 'localhost', :port => 6379, :db => 0}
end

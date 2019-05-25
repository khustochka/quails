url = ENV["REDISTOGO_URL"] || "redis://localhost:6379/0"
Resque.redis = Redis.new(url: url, driver: "hiredis")

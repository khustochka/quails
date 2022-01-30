# frozen_string_literal: true

url = ENV["REDISTOGO_URL"] || ENV["REDIS_RESQUE_URL"]
Resque.redis = Redis.new(url: url, driver: "hiredis")

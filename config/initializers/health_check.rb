# frozen_string_literal: true

HealthCheck.setup do |config|
  # bucket names to test connectivity - required only if s3 check used, access permissions can be mixed
  # config.buckets = {'bucket_name' => [:R, :W, :D]}

  # You can customize which checks happen on a standard health check, eg to set an explicit list use:
  config.standard_checks = [ "database", "migrations", "custom" ]

  # You can set what tests are run with the 'full' or 'all' parameter
  config.full_checks = ["database", "migrations", "custom", "email", "cache", "redis", "resque-redis", "s3"]

  # When redis url/password is non-standard
  config.redis_url = ENV["REDISCLOUD_URL"] || ENV["REDIS_RESQUE_URL"] # default ENV['REDIS_URL']
  # Only included if set, as url can optionally include passwords as well
  # config.redis_password = 'redis_password' # default ENV['REDIS_PASSWORD']
end

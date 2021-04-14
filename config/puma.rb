# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 2 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `environment` that Puma will run in.
rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env
is_production = rails_env == "production"

app_port = ENV['PORT']

# Run on a socket in production if port is not specified
# To run in production locally just specify PORT=3000
if is_production && !app_port

  bind "unix:///run/quails/puma.sock"
else
  # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
  #
  port app_port || 3000
end
# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

workers_num = ENV.fetch("WEB_CONCURRENCY", is_production ? 2 : 1).to_i

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#

if workers_num > 1
  workers workers_num
  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory.
  #
  preload_app!

  if is_production
    # Based on the work of Koichi Sasada and Aaron Patterson, this option may decrease memory utilization
    # of preload-enabled cluster-mode Pumas. It will also increase time to boot and fork. See your logs for
    # details on how much time this adds to your boot process. For most apps, it will be less than one second.
    nakayoshi_fork unless ENV["DYNO"]
  end
end

# Do not raise error when restarted
raise_exception_on_sigterm false

# Allow puma to be restarted by `rails restart` command.
# plugin :tmp_restart

on_worker_boot do
  # if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
  #   ActiveRecord::Base.establish_connection
  # end
  if defined?(Resque)
    require File.expand_path("../initializers/resque_connection", __FILE__)
  end
end

workers Integer(ENV['WEB_CONCURRENCY'] || 4)

threads_count = Integer(ENV['MAX_THREADS'] || 2)
threads 0, threads_count

rails_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

environment rails_env

app_port = ENV['PORT']

# Run on socket in production if port is not specified
if app_port.nil? && rails_env == "production"
  app_dir = File.expand_path("../../../..", __FILE__)
  shared_dir = "#{app_dir}/shared"

  # Keep an eye on this. May be an issue.
  directory "#{app_dir}/current"

  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

  # Do not switch log/pid/state to current dir related path. Supposedly this was the cause of failed restarts.
  # (Would be good to test though).

# Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"
else
  port app_port || 3000
end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.

preload_app!

# If you are preloading your application and using Active Record, it's
# recommended that you close any connections to the database before workers
# are forked to prevent connection leakage.

before_fork do
  if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect!
  end
end

# You should place code to close global log files, redis connections, etc in this block so that their
# file descriptors don't leak into the restarted process. Failure to do so will result in slowly
# running out of descriptors and eventually obscure crashes as the server is restarted many times.

on_restart do
  if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect!
  end
end

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted, this block will be run. If you are using the `preload_app!`
# option, you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, as Ruby
# cannot share connections between processes.

on_worker_boot do
  if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

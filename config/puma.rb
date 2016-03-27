workers Integer(ENV['WEB_CONCURRENCY'] || 2)

threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

app_port = ENV['PORT']
rails_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

environment rails_env

# Run on socket in production if port is not specified
if app_port.nil? && rails_env == "production"
  app_dir = File.expand_path("../../../..", __FILE__)
  shared_dir = "#{app_dir}/shared"

  bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"
else
  port app_port || 3000
end

on_worker_boot do
  if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
  end
end

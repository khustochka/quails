threads_count = Integer(ENV['MAX_THREADS'] || 5)

threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

workers Integer(ENV['WEB_CONCURRENCY'] || 2)

on_worker_boot do
  if defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
  end
end

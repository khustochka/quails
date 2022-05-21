Datadog.configure do |c|
  c.env = Rails.env
  c.tracing.instrument :rails
  c.tracing.instrument :resque

  c.tracing.report_hostname = true
end

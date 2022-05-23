require 'ddtrace'

Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd.match(/releases\/(\d{14})$/)
    c.version = $1
  end
  c.tracing.instrument :rails
  c.tracing.instrument :resque
  c.tracing.instrument :action_cable
  c.tracing.instrument :aws
  c.tracing.instrument :mongo
  c.diagnostics.startup_logs.enabled = false
  c.tracing.report_hostname = true
end

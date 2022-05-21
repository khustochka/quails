require 'ddtrace'

Datadog.configure do |c|
  c.env = Rails.env
  c.tracing.instrument :rails
  c.tracing.instrument :resque
  c.tracing.instrument :action_cable
  c.tracing.instrument :aws
  c.tracing.instrument :mongo

  c.tracing.report_hostname = true
end

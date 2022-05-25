Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd.match(/releases\/(\d{14})$/)
    c.version = $1
  end
  c.tracing.instrument :rails, service_name: "quails"
  c.tracing.instrument :resque
  c.tracing.instrument :aws
  c.tracing.instrument :mongo
  #c.diagnostics.startup_logs.enabled = false
  c.tracing.report_hostname = true
  c.tracing.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
end

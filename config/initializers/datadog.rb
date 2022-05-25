Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd.match(/releases\/(\d{14})$/)
    c.version = $1
  end
  c.tracing.instrument :rails, service_name: "quails", cache_service: "quails-cache", database_service: "quails-postgres"
  c.tracing.instrument :resque, service_name: "quails-resque"
  c.tracing.instrument :aws, service_name: "quails-aws"
  c.tracing.instrument :mongo, service_name: "quails-mongo"
  c.diagnostics.startup_logs.enabled = false
  c.tracing.report_hostname = true
  if !Rails.env.production?
    c.tracing.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
  end
end

Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd.match(/releases\/(\d{14})$/)
    c.version = $1
  end
  c.use :rails, service_name: "quails"
  c.use :resque
  c.use :aws
  c.use :mongo
  #c.diagnostics.startup_logs.enabled = false
  c.report_hostname = true
  c.tracer.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
end

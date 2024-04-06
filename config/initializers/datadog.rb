# frozen_string_literal: true

require "ddtrace/auto_instrument"

Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd =~ %r{releases/(\d{14})$}
    c.version = Regexp.last_match(1)
  end

  c.tracing.instrument :rails, service_name: "quails"
  c.tracing.instrument :pg, service_name: "quails-postgres"
  c.tracing.instrument :active_support, cache_service: "quails-cache"
  c.tracing.instrument :resque, service_name: "quails-resque"
  c.tracing.instrument :aws, service_name: "quails-aws"
  c.tracing.instrument :mongo, service_name: "quails-mongo"
  c.diagnostics.startup_logs.enabled = true
  c.tracing.report_hostname = true

  c.tracing.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
end

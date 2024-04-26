# frozen_string_literal: true

if ENV["DD_ENABLED"]
  require "ddtrace/auto_instrument"

  TRACED_TASKS = ["quails:five_mr:refresh", "quails:ebird:checklists_preload"]

  Datadog.configure do |c|
    if Dir.pwd =~ %r{releases/(\d{14})$}
      c.version = Regexp.last_match(1)
    end

    c.tracing.instrument :rails, service_name: "quails"
    c.tracing.instrument :active_record, service_name: "quails-postgres"
    c.tracing.instrument :active_support, cache_service: "quails-rails-cache"
    c.tracing.instrument :resque, service_name: "quails-resque"
    c.tracing.instrument :aws, service_name: "quails-aws"
    c.tracing.instrument :mongo, service_name: "quails-mongo"

    if defined?(Rake)
      c.tracing.instrument :rake, tasks: TRACED_TASKS, service_name: "quails-rake"
    end

    # Use DD_TRACE_STARTUP_LOGS for startup logs
    # c.diagnostics.startup_logs.enabled = true
    c.tracing.report_hostname = true

    c.tracing.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
  end
end

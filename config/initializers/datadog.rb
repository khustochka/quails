# frozen_string_literal: true

if ENV["DD_ENABLED"].in?(["true", "1"])
  require "datadog/auto_instrument"

  TRACED_TASKS = ["quails:five_mr:refresh", "quails:ebird:checklists_preload", "quails:email:test"]

  Datadog.configure do |c|
    if Dir.pwd =~ %r{releases/(\d{14})$}
      c.version = Regexp.last_match(1)
    end

    c.tracing.instrument :rails
    c.tracing.instrument :active_record
    c.tracing.instrument :active_support
    c.tracing.instrument :aws
    c.tracing.instrument :mongo

    if defined?(Rake)
      c.tracing.instrument :rake, tasks: TRACED_TASKS
    end

    # Use DD_TRACE_STARTUP_LOGS for startup logs
    # c.diagnostics.startup_logs.enabled = true
    c.tracing.report_hostname = true

    c.tracing.enabled = Datadog::Core::Environment::VariableHelpers.env_to_bool("DD_TRACE_ENABLED")
  end
end

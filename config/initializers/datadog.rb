# frozen_string_literal: true

if ENV["QUAILS_DD_ENABLED"].in?(["true", "1"])
  require "datadog/auto_instrument"

  TRACED_TASKS = ["quails:five_mr:refresh", "quails:ebird:checklists_preload", "quails:email:test"]

  Datadog.configure do |c|
    if Dir.pwd =~ %r{releases/(\d{14})$}
      c.version = Regexp.last_match(1)
    end

    c.tracing.instrument :rails, service_name: "quails"
    c.tracing.instrument :active_record, service_name: "quails-postgres"
    c.tracing.instrument :active_support, cache_service: "quails-rails-cache"
    c.tracing.instrument :aws # Autodetected
    c.tracing.instrument :semantic_logger

    if defined?(Rake)
      c.tracing.instrument :rake, tasks: TRACED_TASKS
    end

    # Use DD_TRACE_STARTUP_LOGS for startup logs
    # c.diagnostics.startup_logs.enabled = true
    c.tracing.report_hostname = true
  end

  # Drop the trace for successful "/up" health checks so they don't clutter
  # Datadog. Non-2xx health checks are kept so failures stay visible, and other
  # actions on the same controller (e.g. "/healthy") are not affected.
  Datadog::Tracing.before_flush(
    Datadog::Tracing::Pipeline::SpanFilter.new do |span|
      span.name == "rack.request" &&
      span.status == "success" &&
        URI.parse(span.get_tag("http.url").to_s).path == "/up"
    end
  )
end

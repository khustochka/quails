# frozen_string_literal: true

RailsPgExtras.configure do |config|
  config.public_dashboard = true

  config.enabled_web_actions = [:kill_pid, :pg_stat_statements_reset]
end

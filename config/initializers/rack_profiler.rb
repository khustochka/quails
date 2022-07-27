# frozen_string_literal: true

# TODO: only for web
Rails.application.config.x.features.rack_profiler = !!YAML.load(ENV["RACK_PROFILER"].to_s)

if Rails.application.config.x.features.rack_profiler
  require "rack-mini-profiler"

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end

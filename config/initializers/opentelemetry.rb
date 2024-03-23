# frozen_string_literal: true

if ENV["TRACING"] == true
  require "tracing/quantization/http"

  OpenTelemetry::SDK.configure do |c|
    c.service_name = "quails-#{Rails.env}"
    c.use_all(
      "OpenTelemetry::Instrumentation::Rack" => { application: Rails.application, url_quantization: Tracing::Quantization::HTTP }
    )
  end
end

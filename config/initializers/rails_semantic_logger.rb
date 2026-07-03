# frozen_string_literal: true

# Log format is configured per-environment (see config/environments/*):
#   development / test          : human-readable Rails format.
#   production                  : logfmt "key=value" line.
#   production + QUAILS_LOG_JSON : JSON, for Datadog ingestion.
#
# The Datadog "dd" trace-correlation field is injected automatically by
# datadog's semantic_logger integration, so nothing is wired up here.

# In logfmt output, render request params as a compact JSON string rather than
# an inspected Ruby hash. Rails patches String#to_json to html-escape ">"/"&"
# (as >/&); the logfmt formatter runs every value through that, which
# mangles the params. Wrapping the JSON in an object whose #to_json delegates to
# JSON.generate (which does not html-escape) yields a valid, quoted logfmt value
# like: params="{\"locus\":\"canada\"}". Skipped in JSON mode, where params stay
# a real nested object.
unless ENV["QUAILS_LOG_JSON"].in?(%w(true 1))
  # #to_json returns the JSON-quoted string without html-escaping, so the
  # formatter emits it as one properly quoted logfmt field.
  raw_json = Struct.new(:string) do
    def to_json(*) = JSON.generate(string)
    def to_s = string
    def inspect = string
  end

  SemanticLogger.on_log do |log|
    params = log.payload && log.payload[:params]
    log.payload[:params] = raw_json.new(JSON.generate(params)) if params.is_a?(Hash)
  end
end

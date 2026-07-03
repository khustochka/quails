# frozen_string_literal: true

# Log format is configured per-environment (see config/environments/*):
#   development / test          : human-readable Rails format.
#   production                  : logfmt "key=value" line.
#   production + QUAILS_LOG_JSON : JSON, for Datadog ingestion.
#
# The Datadog "dd" trace-correlation field is injected automatically by
# datadog's semantic_logger integration, so nothing is wired up here.

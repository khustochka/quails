# frozen_string_literal: true

# Parse application/csp-report as JSON
original_parsers = ActionDispatch::Request.parameter_parsers
json_parser = original_parsers[:json]
new_parsers = original_parsers.merge(csp_report: json_parser)
ActionDispatch::Request.parameter_parsers = new_parsers

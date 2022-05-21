Datadog.configure do |c|
  c.service = 'quails'
  c.env = Rails.env

  c.tracing.report_hostname = true
end

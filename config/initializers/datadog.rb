require 'ddtrace'

Datadog.configure do |c|
  c.env = Rails.env
  if Dir.pwd.match(/releases\/(\d{14})$/)
    c.version = $1
  end
  c.use :rails, service_name: "quails"
  c.use :resque
  c.use :action_cable
  c.use :aws
  c.use :mongo
  #c.diagnostics.startup_logs.enabled = false
  c.report_hostname = true
end

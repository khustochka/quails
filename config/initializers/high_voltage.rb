HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
  config.layout = 'application2'
  # Override routes manually
  config.routes = false
end

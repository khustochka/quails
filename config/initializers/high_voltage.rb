HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
  # Override routes manually
  config.routes = false
end

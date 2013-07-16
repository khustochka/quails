# Load the rails application.
require File.expand_path('../application', __FILE__)

begin
# Initialize the rails application.
  Quails::Application.initialize!
rescue Errno::ENOENT
  raise "Missing database setup. Run `rake init` to create basic config/database.yml
            and edit it as appropriate."
end

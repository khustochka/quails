# Load the Rails application.
require File.expand_path('../application', __FILE__)

begin
  # Initialize the Rails application.
  Rails.application.initialize!
rescue Errno::ENOENT
  raise "Missing database setup. Run `rake init` to create basic config/database.yml
            and edit it as appropriate."
end

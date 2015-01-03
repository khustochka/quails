# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'quails/env'

begin
  # Initialize the Rails application.
  Rails.application.initialize!
rescue Errno::ENOENT
  raise "Missing database setup. Run `rake init` to create basic config/database.yml
            and edit it as appropriate."
end

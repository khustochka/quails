# Load the rails application
require File.expand_path('../application', __FILE__)

begin
# Initialize the rails application
  Quails3::Application.initialize!
rescue Errno::ENOENT
  require 'fileutils'
  FileUtils.cp 'config/database.sample.yml', 'config/database.yml'
  raise 'Created config/database.yml. Please edit it as appropriate'
end

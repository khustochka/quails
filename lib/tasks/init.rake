desc 'Init application. Copy necessary configuration files'
task :init do
  require 'fileutils'
  FileUtils.cp 'config/database.sample.yml', 'config/database.yml'
  FileUtils.cp 'config/security.sample.yml', 'config/security.yml'
end
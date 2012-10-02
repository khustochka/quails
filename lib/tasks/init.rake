desc 'Init application. Copy necessary configuration files'
task :init do
  require 'fileutils'
  %w(database security).each do |aspect|
    file = "config/#{aspect}.yml"
    if File.exist?(file)
      puts "--- File #{file} exists."
    else
      puts "--- Creating #{file}. Please edit as appropriate."
      FileUtils.cp "config/#{aspect}.sample.yml", file
    end
  end
end
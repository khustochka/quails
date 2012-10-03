desc 'Init application. Copy necessary configuration files'
task :init do
  require 'fileutils'
  %w(database security).each do |aspect|
    filename = "config/#{aspect}.yml"
    if File.exist?(filename)
      puts "--- File #{filename} exists."
    else
      puts "--- Creating #{filename}. Please edit as appropriate."

      template = ERB.new(File.read("config/#{aspect}.sample.yml"))


      File.open(filename, "w") do |file|
        file.puts template.result
      end
    end
  end
end
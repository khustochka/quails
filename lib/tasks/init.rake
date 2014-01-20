desc 'Init application. Copy necessary configuration files'
multitask :init => ["config/database.yml", "config/local.yml"]

file "config/database.yml" do
  system "erb config/database.sample.yml > config/database.yml"
end

file "config/local.yml" do
  system %Q(echo repo: /home/#{`whoami`.chomp}/bwdata > config/local.yml)
end

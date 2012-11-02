desc 'Init application. Copy necessary configuration files'
multitask :init => ["config/database.yml", "config/security.yml"]

file "config/database.yml" do
  system "erb config/database.sample.yml > config/database.yml"
end

file "config/security.yml" do
  system "erb -r securerandom config/security.sample.yml > config/security.yml"
end

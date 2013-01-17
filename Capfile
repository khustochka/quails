load 'deploy'

#Dir['vendor/gems/*/recipes/*.rb', 'vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

config_repo = File.expand_path(File.dirname(__FILE__)) + "/config/deploy"
#system "git --git-dir=#{config_repo}/.git --work-tree=#{config_repo} pull"
system "(cd #{config_repo}; git pull)"

load 'config/deploy/deploy'

default_run_options[:pty] = true

Dir['lib/cap/*.rb'].each { |plugin| load(plugin) }

load 'deploy'

#Dir['vendor/gems/*/recipes/*.rb', 'vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy/deploy'

default_run_options[:pty] = true

Dir['lib/cap/*.rb'].each { |plugin| load(plugin) }

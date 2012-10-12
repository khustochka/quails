load 'deploy'

#Dir['vendor/gems/*/recipes/*.rb', 'vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy' # remove this line to skip loading any of the default tasks

default_run_options[:pty] = true

load "./lib/cap/bundler"

load "./lib/cap/config"

load "./lib/cap/assets"

load "./lib/cap/db"

load "./lib/cap/server"

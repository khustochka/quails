require "bundler/capistrano"

set :bundle_without,  [:development, :test, :heroku]
after "deploy:cleanup", "bundle:clean"

namespace :bundle do
  task :clean, :except => {:no_release => true} do
    bundle_cmd = fetch(:bundle_cmd, "bundle")
    run "cd #{latest_release} && #{bundle_cmd} clean"
  end
end

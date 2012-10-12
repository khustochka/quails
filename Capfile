load 'deploy'
# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
#Dir['vendor/gems/*/recipes/*.rb', 'vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy' # remove this line to skip loading any of the default tasks

default_run_options[:pty] = true

require "bundler/capistrano"
set :bundle_flags,    "--deployment"
set :bundle_without,  [:development, :test, :heroku]
after "bundle:install", "bundle:clean"

namespace :bundle do
  task :clean, :except => {:no_release => true} do
    bundle_cmd = fetch(:bundle_cmd, "bundle")
    run "cd #{latest_release} && #{bundle_cmd} clean"
  end
end

# Helper method to upload to /tmp then use sudo to move to correct location.
def put_sudo(data, to)
  filename = File.basename(to)
  to_directory = File.dirname(to)
  put data, "/tmp/#{filename}"
  run "#{sudo} mv /tmp/#{filename} #{to_directory}"
end

namespace :config do

  desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template
      called database.yml.erb is found either is :template_dir
      or /config/deploy folders. The default template matches
      the template for config/database.yml file shipped with Rails.

      When this recipe is loaded, db:setup is automatically configured
      to be invoked after deploy:setup. You can skip this task setting
      the variable :skip_db_setup to true. This is especially useful
      if you are using this recipe in combination with
      capistrano-ext/multistaging to avoid multiple db:setup calls
      when running deploy:setup for all stages one by one.
  DESC
  task :setup, :except => {:no_release => true} do

    run "#{try_sudo} mkdir -p #{shared_path}/db #{shared_path}/config"
    run "#{try_sudo} chmod g+w #{shared_path}/db #{shared_path}/config"

    require "securerandom"

    %w(database security).each do |aspect|
      location = fetch(:template_dir, "config") + "/#{aspect}.sample.yml"
      template = File.read(location)

      config = ERB.new(template)
      put_sudo config.result(binding), "#{shared_path}/config/#{aspect}.yml"
      #put template, "#{shared_path}/config/#{aspect}.yml"
    end
  end

  desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
  DESC
  task :symlink, :except => {:no_release => true} do
    %w(database security local).each do |aspect|
      run "ln -nfs #{shared_path}/config/#{aspect}.yml #{release_path}/config/#{aspect}.yml"
    end
  end

end

after "deploy:setup", "config:setup" unless fetch(:skip_config_setup, false)
after "deploy:finalize_update", "config:symlink"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => {:no_release => true} do
      first_deploy = !(current_revision rescue false) # Prevent failure on first deploy
      from = source.next_revision(current_revision) unless first_deploy
      if first_deploy || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ lib/assets | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end

    end
  end
end

namespace :db do
  desc 'Restore the database from local backup'
  task :restore, :roles => :db do
    run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} legacy:import }
  end
end

namespace :deploy do

  desc <<-DESC
    Start server
  DESC
  task :start, :roles => :app do
    run "sudo service #{fetch(:service)} start"
  end

  desc <<-DESC
    Stop server
  DESC
  task :stop, :roles => :app do
    run "sudo service #{fetch(:service)} stop"
  end

  desc <<-DESC
    Start server
  DESC
  task :restart, :roles => :app do
    run "sudo service #{fetch(:service)} upgrade"
  end

end

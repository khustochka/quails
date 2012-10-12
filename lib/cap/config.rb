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

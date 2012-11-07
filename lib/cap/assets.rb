# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

#namespace :deploy do
#  namespace :assets do
#    task :precompile, :roles => :web, :except => {:no_release => true} do
#      first_deploy = !(current_revision rescue false) # Prevent failure on first deploy
#      from = source.next_revision(current_revision) unless first_deploy
#      if first_deploy || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ lib/assets | wc -l").to_i > 0
#        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
#      else
#        logger.info "Skipping asset pre-compilation because there were no asset changes"
#      end
#
#    end
#  end
#end

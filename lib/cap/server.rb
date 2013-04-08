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
    Restart server
  DESC
  task :restart, :roles => :app do
    stop
    start
    #run "sudo service #{fetch(:service)} upgrade"
    #stream "tail -f #{current_path}/log/unicorn.log"
  end

end

# http://almosteffortless.com/2009/06/25/config-vars-and-heroku/ for details

desc 'Push the security.yml options for production env as config vars on heroku'
namespace :heroku do
  task :config do
    puts "Reading config/security.yml and sending config vars to Heroku..."
    configs = YAML.load_file('config/security.yml')['production']
    command = 'heroku config:add'
    configs.each {|key, val| command << " #{key}=#{val} " if val }
    puts command
    system command
  end
end

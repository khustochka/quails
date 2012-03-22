desc 'Jquery-ujs tasks'
namespace :ujs do
  desc 'Update jquery-ujs'
  task :update do
    system "curl https://raw.github.com/rails/jquery-ujs/master/src/rails.js > public/js/rails.js"
  end
end

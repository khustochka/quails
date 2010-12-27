desc 'Update jquery-ujs'
task :update_ujs do
  system "curl https://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js"
end
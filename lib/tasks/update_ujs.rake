desc 'Update jquery-ujs'
task :update_ujs do
  system "curl https://raw.github.com/rails/jquery-ujs/master/src/rails.js > public/javascripts/rails.js"
end
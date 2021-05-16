# frozen_string_literal: true

desc 'Update vendor assets'
namespace :vendor do

  desc 'Update vendored JS and CSS'
  task :update => %w(update:javascripts update:css)

  namespace :update do

    #desc 'Update Javascripts'
    task :javascripts do
      puts "\n=== Getting latest HTML5shiv for IE ==="
      system "curl https://raw.githubusercontent.com/aFarkas/html5shiv/master/src/html5shiv.js -o vendor/assets/javascripts/html5.js"
      #puts "\n=== Getting latest JSON3 parser for IE ==="
      #system "curl https://raw.githubusercontent.com/bestiejs/json3/gh-pages/lib/json3.js -o vendor/assets/javascripts/json3.js"
      puts "\n=== Getting Gmap3 ==="
      system "curl https://raw.githubusercontent.com/khustochka/gmap3/quails_gmap3_v6/dist/gmap3.js -o vendor/assets/javascripts/gmap3.js"
    end

    #desc 'Update CSS'
    task :css do
      # If upgrading to higher version of normalize.css please check in IE7 if necessary
      puts "\n=== Getting latest normalize.css ==="
      system "curl https://raw.githubusercontent.com/necolas/normalize.css/v1/normalize.css -o vendor/assets/stylesheets/normalize.css"
    end

  end

end

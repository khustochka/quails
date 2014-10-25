desc 'Update vendor assets'
namespace :vendor do

  namespace :update do

    desc 'Update vendored JS and CSS'
    task :assets => [:javascripts, :css]

    #desc 'Update Javascripts'
    task :javascripts do
      require './config/initializers/jquery'

      puts "\n=== Getting JQuery #{JQUERY_CDN.scan(/\d\.\d\.\d/)[0]} ==="
      system "curl http:#{JQUERY_CDN} -o vendor/assets/javascripts/jquery.min.js"
      puts "\n=== Getting latest JQuery-ujs ==="
      system "curl https://raw.githubusercontent.com/rails/jquery-ujs/master/src/rails.js -o vendor/assets/javascripts/jquery_ujs.js"
      puts "\n=== Getting latest JQuery-pjax ==="
      system "curl https://raw.githubusercontent.com/defunkt/jquery-pjax/master/jquery.pjax.js -o vendor/assets/javascripts/jquery_pjax.js"
      puts "\n=== Getting latest Keypress.js ==="
      system "curl https://raw.githubusercontent.com/dmauro/Keypress/v1.0/keypress.js -o vendor/assets/javascripts/keypress.js"
      puts "\n=== Getting latest HTML5shiv for IE ==="
      system "curl http://html5shiv.googlecode.com/svn/trunk/html5.js -o vendor/assets/javascripts/html5.js"
      puts "\n=== Getting latest JSON3 parser for IE ==="
      system "curl https://raw.githubusercontent.com/bestiejs/json3/gh-pages/lib/json3.js -o vendor/assets/javascripts/json3.js"
      puts "\n=== Getting Gmap3 ==="
      system "curl https://raw.githubusercontent.com/khustochka/gmap3/quails_gmap3/gmap3.js -o vendor/assets/javascripts/gmap3.js"
    end

    #desc 'Update CSS'
    task :css do
      puts "\n=== Getting latest normalize.css ==="
      system "curl https://raw.githubusercontent.com/necolas/normalize.css/v1/normalize.css -o vendor/assets/stylesheets/normalize.css"
    end

  end

end

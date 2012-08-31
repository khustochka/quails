desc 'Update vendor assets'
namespace :vendor do

  namespace :update do

    desc 'Update vendored JS and CSS'
    task :assets => [:javascripts, :css]

    #desc 'Update Javascripts'
    task :javascripts do
      JQUERY_VERSION = '1.8.1'
      puts "\n=== Getting JQuery #{JQUERY_VERSION} ==="
      system "curl http://code.jquery.com/jquery-#{JQUERY_VERSION}.js > vendor/assets/javascripts/jquery.js"
      puts "\n=== Getting latest JQuery-ujs ==="
      system "curl https://raw.github.com/rails/jquery-ujs/master/src/rails.js > vendor/assets/javascripts/jquery_ujs.js"
      puts "\n=== Getting latest JQuery-pjax ==="
      system "curl https://raw.github.com/defunkt/jquery-pjax/master/jquery.pjax.js > vendor/assets/javascripts/jquery_pjax.js"
      puts "\n=== Getting latest HTML5shiv for IE ==="
      system "curl http://html5shiv.googlecode.com/svn/trunk/html5.js > vendor/assets/javascripts/html5.js"
      puts "\n=== Getting latest Gmap3 ==="
      system "curl https://raw.github.com/khustochka/gmap3/one-marker-cluster/gmap3.js > vendor/assets/javascripts/gmap3.js"
    end

    #desc 'Update CSS'
    task :css do
      puts "\n=== Getting latest normalize.css ==="
      system "curl https://raw.github.com/necolas/normalize.css/v1/normalize.css > vendor/assets/stylesheets/normalize.css"
    end

  end

end

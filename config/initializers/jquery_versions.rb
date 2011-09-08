JQUERY_VERSION = '1.6.3'

JQUERY_URL = Rails.env.production? ?
    "http://ajax.googleapis.com/ajax/libs/jquery/#{JQUERY_VERSION}/jquery.min.js" :
    "jquery-#{JQUERY_VERSION}.min"

Dir['public/javascripts/*.js'].each do |path|
  if File.basename(path) =~ /jquery-ui*/
    JQ_UI_FILE = File.basename(path, '.js')
    break
  end
end
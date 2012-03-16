JQUERY_VERSION = '1.7.1'

JQUERY_URL = Rails.env.production? ?
    "http://ajax.googleapis.com/ajax/libs/jquery/#{JQUERY_VERSION}/jquery.min.js" :
    "/js/jquery-#{JQUERY_VERSION}.min"

Dir['public/js/*.js'].each do |path|
  if File.basename(path) =~ /jquery-ui*/
    JQ_UI_FILE = File.basename(path, '.js')
    break
  end
end
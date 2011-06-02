JQUERY_VERSION = '1.6.1'

Dir['public/javascripts/*.js'].each do |path|
  if File.basename(path).match(/jquery-ui*/)
    JQ_UI_FILE = File.basename(path, '.js')
    break
  end
end
JQUERY_CDN = "http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"
JQUERYUI_CDN = "http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"

JQUERY_URL = Rails.env.production? ? JQUERY_CDN : "jquery.min.js"

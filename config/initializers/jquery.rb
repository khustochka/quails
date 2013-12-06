# Jquery series 2.x does not support IE7 properly (e.g .the Map page)
JQUERY_CDN = "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"
JQUERYUI_CDN = "//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"

JQUERY_URL = Rails.env.production? ? JQUERY_CDN : "jquery.min.js"

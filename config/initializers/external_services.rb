require 'service_code/google_search'
require 'service_code/google_analytics'
require 'service_code/facebook_sdk'
require 'service_code/vkontakte_sdk'

GoogleAnalytics.configure(ENV['quails_ga_code'])
GoogleSearch.configure(ENV['quails_google_cse'])
FacebookSdk.configure(ENV['quails_facebook_app_id'])
VkontakteSdk.configure(ENV['quails_vkontakte_app_id'])






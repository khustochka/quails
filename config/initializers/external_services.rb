require "configurator"
require 'service_code/google_search'
require 'service_code/google_analytics'
require 'service_code/facebook_sdk'
require 'service_code/vkontakte_sdk'

Configurator.configure_google_search

Configurator.configure_google_analytics

Configurator.configure_facebook_sdk

Configurator.configure_vkontakte_sdk

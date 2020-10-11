# frozen_string_literal: true

FlickRaw.api_key = ENV['quails_flickr_app_key']
FlickRaw.shared_secret = ENV['quails_flickr_app_secret']

is_configured = !!(FlickRaw.api_key && FlickRaw.shared_secret)

FlickRaw.instance_eval("def configured?; #{is_configured}; end")

undef flickr # remove global flickr method defined by FlickRaw

require "configurator"

Configurator.configure_secret_token

undef flickr # remove global flickr method defined by FlickRaw

Comment.negative_captcha = SecureRandom.hex(8).to_s

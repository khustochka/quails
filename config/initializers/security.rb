require 'credentials_verifier'

file = Rails.env.production? ? 'config/security.yml' : 'config/security_devtest.yml'

options = YAML.load(ERB.new(File.read(file)).result)[Rails.env]

IMAGES_HOST = options['images_host']

FlickRawOptions = options['flickr'].merge({"lazyload" => true})

CredentialsVerifier.init Hashie::Mash.new(options)
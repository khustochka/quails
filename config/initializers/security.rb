require 'credentials_verifier'

file = Rails.env.production? ? 'config/security.yml' : 'config/security_devtest.yml'

options = YAML.load(ERB.new(File.read(file)).result)[Rails.env]

IMAGES_HOST = options['images_host']

FlickRawOptions = options['flickr'].merge({"lazyload" => true})

require 'flickraw'

CredentialsVerifier.init Hashie::Mash.new(options)

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Quails3::Application.config.secret_token = options['secret_token']

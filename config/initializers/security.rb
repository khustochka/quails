filename = Rails.env.production? ? 'config/security.yml' : 'config/security_devtest.yml'

options = YAML.load(ERB.new(File.read(filename)).result)[Rails.env]

IMAGES_HOST = options['images_host']

FlickRawOptions = options['flickr'].merge({"lazyload" => true})
require 'flickraw'

require 'credentials_verifier'
CredentialsVerifier.init Hashie::Mash.new(options)

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
secret = options['secret_token']
if secret.blank? || secret.length < 30
  raise ArgumentError, "A secret is required to generate an " +
    "integrity hash for cookie session data. Use " +
    "SecureRandom.hex(30) to generate a secret " +
    "of at least 30 characters and store it " +
    "in config/security.yml"
end
Quails3::Application.config.secret_token = secret

filename = Rails.env.production? ? 'config/security.yml' : 'config/security_devtest.yml'

options = YAML.load(ERB.new(File.read(filename)).result)[Rails.env]

require 'credentials_verifier'
CredentialsVerifier.init(options['admin'])

secret = options['secret_token']
if secret.blank? || secret.length < 30
  raise ArgumentError, "A secret is required to generate an " +
      "integrity hash for cookie session data. Use " +
      "SecureRandom.hex(30) to generate a secret " +
      "of at least 30 characters and store it " +
      "in config/security.yml"
end
Quails3::Application.config.secret_token = secret

IMAGES_HOST = options['images_host']

if options['flickr']
  FlickRaw.api_key = options['flickr']['api_key']
  FlickRaw.shared_secret = options['flickr']['shared_secret']

  flickr.access_token = options['flickr']['access_token']
  flickr.access_secret = options['flickr']['access_key']
end
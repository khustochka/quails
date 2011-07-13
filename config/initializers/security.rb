require 'credentials_verifier'

options = YAML.load(ERB.new(File.read('config/security.yml')).result)[Rails.env]

IMAGES_HOST = options['images_host']

CredentialsVerifier.init Hashie::Mash.new(options)
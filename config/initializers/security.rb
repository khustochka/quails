require 'credentials_verifier'

file = 'config/security.yml'

options = YAML.load(ERB.new(File.read('config/security.yml')).result)[Rails.env]

CredentialsVerifier.init Hashie::Mash.new(options)
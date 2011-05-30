require 'credentials_verifier'

options = YAML.load(ERB.new(File.read('config/security.yml')).result)[Rails.env]

CredentialsVerifier.init Hashie::Mash.new(options)
require 'lib/credentials_verifier'

options = YAML::load_file('config/security.yml')[Rails.env]
CredentialsVerifier.init Hashie::Mash.new(options)
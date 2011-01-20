require 'lib/credentials_verifier'

ALLOWED_KEYS = ['username', 'password']

file = 'config/security.yml'

options = if File.exist?('config/security.yml')
            YAML::load_file('config/security.yml')[Rails.env]
          else
            ALLOWED_KEYS.inject({}) {|memo, key| memo.merge!({key => ENV[key]})}
          end

CredentialsVerifier.init Hashie::Mash.new(options)
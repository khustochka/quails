# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

secret = ENV['quails_secret_token']

if secret.blank?
  unless Quails.env.rake?
    raise "Secret token is not configured!"
  end
end

Quails::Application.config.secret_key_base = secret

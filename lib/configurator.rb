require "quails/env"

module Configurator

  def self.configure_secret_token
    secret = ENV['quails_secret_token']
    if secret.blank?
      unless Quails.env.rake?
        raise "Secret token is not configured!"
      end
    end
    Quails::Application.config.secret_key_base = secret
  end

  def self.configure_errbit
    if ENV['errbit_api_key'] && ENV['errbit_host']
      Airbrake.configure do |config|
        config.api_key = ENV['errbit_api_key']
        config.host = ENV['errbit_api_key']
        config.port = 443 #80
        config.secure = config.port == 443
        config.ignore_only = []
      end
    end
  end

end

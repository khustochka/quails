require "quails/env"

module Configurator

  def self.configure(klass)
    case klass.name
      when 'User'
        User.configure(config_data.admin)
      when 'ImagesHelper'
        ImagesHelper.image_host = config_data.image_host
        ImagesHelper.local_image_path = config_data.local_image_path
        ImagesHelper.temp_image_path = config_data.temp_image_path
      when 'CommentMailer'
        CommentMailer.default from: config_data.mail.try(:sender)
        CommentMailer.default to: config_data.mail.try(:reader)
    end
  end

  def self.configure_secret_token
    secret = config_data.secret_token
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

  private

  def self.config_data
    @config_data ||= Hashie::Mash.new(read_config_from_env_vars)
  end

  def self.read_config_from_env_vars
    {
        admin: {
            username: ENV['admin_username'],
            password: ENV['admin_password'],
            cookie_value: ENV['admin_cookie_value']
        },
        secret_token: ENV['quails_secret_token'],
        image_host: ENV['quails_image_host'],
        local_image_path: ENV['quails_local_image_path'],
        temp_image_path: ENV['quails_temp_image_path'],
        mail: {
            sender: ENV['quails_mail_sender'],
            reader: ENV['quails_mail_reader']
        }
    }
  end

end

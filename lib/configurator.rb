require "quails/env"

module Configurator

  def self.configure(klass)
    case klass.name
      when 'User'
        User.configure(config_data.admin)
      when 'ImagesHelper'
        ImagesHelper.image_host = config_data.image_host
        ImagesHelper.local_image_path = config_data.local_image_path
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
    errbit = Hashie::Mash.new(config_data.errbit)
    if errbit && errbit.api_key && errbit.host
      Airbrake.configure do |config|
        config.api_key = errbit.api_key
        config.host = errbit.host
        config.port = 80
        config.secure = config.port == 443
        config.ignore_only = []
      end
    end
  end

  def self.configure_google_search
    GoogleSearch.configure(config_data.google_cse)
  end

  def self.configure_facebook_sdk
    FacebookSdk.configure(config_data.facebook_app_id)
  end

  def self.configure_google_analytics
    GoogleAnalytics.configure(config_data.ga_code)
  end

  private

  def self.config_data
    @config_data ||= Hashie::Mash.new(read_config)
  end

  def self.read_config
    if Quails.env.configured?
      read_config_from_env_vars
    else
      YAML.load(ERB.new(File.read('config/security.yml')).result)[Rails.env]
    end
  rescue Errno::ENOENT
    if Rails.env.test?
      test_configuration
    else
      msg = "Missing configuration. Run `rake init` to create basic config/security.yml
            and edit it as appropriate. Or set the environment variables."
      if Quails.env.rake?
        STDERR.puts msg
      else
        raise msg
      end
    end
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
        errbit: {
            api_key: ENV['errbit_api_key'],
            host: ENV['errbit_host']
        },
        google_cse: ENV['quails_google_cse'],
        facebook_app_id: ENV['quails_facebook_app_id'],
        ga_code: ENV['quails_ga_code'],
        mail: {
            sender: ENV['quails_mail_sender'],
            reader: ENV['quails_mail_reader']
        }
    }
  end

  def self.test_configuration
    {
        admin: {
            username: 'test',
            password: 'test',
            cookie_value: 'test'
        },
        secret_token: SecureRandom.hex(30),
        image_host: 'http://localhost/photos'
    }
  end

end

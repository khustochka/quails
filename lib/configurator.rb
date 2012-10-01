require "ostruct"

module Configurator

  def self.configure(klass)
    case klass.name
      when 'User'
        User.configure(config_data.admin)
      when 'ImagesHelper'
        ImagesHelper.image_host = config_data.image_host
    end
  end

  def self.configure_secret_token
    secret = config_data.secret_token
    if secret.blank? || secret.length < 30
      raise ArgumentError, "A secret is required to generate an " +
          "integrity hash for cookie session data. Use " +
          "SecureRandom.hex(30) to generate a secret " +
          "of at least 30 characters and store it " +
          "in config/security.yml"
    end
    Quails::Application.config.secret_token = secret
  end

  private

  def self.config_data
    @config_data ||= read_config
  end

  def self.read_config
    OpenStruct.new(
        if ENV['QUAILS_ENV'].try(:include?, 'heroku')
          read_config_from_env_vars
        else
          YAML.load(ERB.new(File.read('config/security.yml')).result)[Rails.env]
        end
    )
  rescue Errno::ENOENT
    raise "Missing configuration. Run `rake init` to create basic config/security.yml
            and edit it as appropriate. Or set the environment variables."
  end

  def self.read_config_from_env_vars
    {
        admin: {
            username: ENV['admin_username'],
            password: ENV['admin_password'],
            cookie_value: ENV['admin_cookie_value']
        },
        secret_token: ENV['quails_secret_token'],
        image_host: ENV['quails_image_host']
    }
  end

end

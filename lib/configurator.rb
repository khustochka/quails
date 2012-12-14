require "quails/env"

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
    if secret.blank? && !Quails.env.background?
      $stderr.puts("[WARN] Secret token is not configured! Please set it unless this is a CLI task")
    end
    Quails::Application.config.secret_token = secret
  end

  def self.configure_errbit
    errbit = Hashie::Mash.new(config_data.errbit)
    if errbit && errbit.api_key && errbit.host
      require "airbrake"
      Airbrake.configure do |config|
        config.api_key = errbit.api_key
        config.host    = errbit.host
        config.port    = 80
        config.secure  = config.port == 443
      end
    end
  end

  private

  def self.config_data
    @config_data ||= read_config
  end

  def self.read_config
    Hashie::Mash.new(
        if Quails.env.configured?
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
        image_host: ENV['quails_image_host'],
        errbit: {
            api_key: ENV['errbit_api_key'],
            host: ENV['errbit_host']
        }
    }
  end

end

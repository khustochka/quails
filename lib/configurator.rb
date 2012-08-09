require "ostruct"

module Configurator

  def self.configure(klass)
    if klass == User
      User.configure(config_data.admin)
    end
  end

  def self.configure_secret_token
    secret = ENV['secret_token'] || config_data.secret_token
    if secret.blank? || secret.length < 30
      raise ArgumentError, "A secret is required to generate an " +
          "integrity hash for cookie session data. Use " +
          "SecureRandom.hex(30) to generate a secret " +
          "of at least 30 characters and store it " +
          "in config/security.yml"
    end
    Quails3::Application.config.secret_token = secret
  end

  private

  def self.config_data
    @config_data ||= read_config
  end

  def self.read_config
    filename = 'config/security.yml'
    OpenStruct.new(YAML.load(ERB.new(File.read(filename)).result)[Rails.env])
  rescue Errno::ENOENT
    require 'fileutils'
    FileUtils.cp 'config/security.sample.yml', filename
    err_msg = 'Created config/security.yml. Please edit it as appropriate'
    if Rails.env.production?
      Rails.logger.warn err_msg
      retry
    else
      raise err_msg
    end
  end

end

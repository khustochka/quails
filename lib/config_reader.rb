require "ostruct"

module ConfigReader

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

  def self.configure(klass)
    if klass == User
      User.configure(config_data.admin)
    end
  end

end

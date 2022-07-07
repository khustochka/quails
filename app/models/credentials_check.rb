# frozen_string_literal: true

module CredentialsCheck
  class << self
    attr_accessor :username, :password
  end

  def self.check_credentials(username, password)
    username == __username &&
      (BCrypt::Password.valid_hash?(__password) && BCrypt::Password.new(__password).is_password?(password)) ||
      (!Rails.env.production? && password == __password)
  end

  def self.__username
    self.username ||= ENV["admin_username"]
  end

  def self.__password
    self.password ||= ENV["admin_password"]
  end
end

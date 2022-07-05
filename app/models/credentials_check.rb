# frozen_string_literal: true

module CredentialsCheck
  def self.check_credentials(username, password)
    username == __username &&
      (BCrypt::Password.valid_hash?(__password) && BCrypt::Password.new(__password).is_password?(password)) ||
      (!Rails.env.production? && password == __password)
  end

  def self.__username
    @@username ||= ENV["admin_username"]
  end

  def self.__password
    @@password ||= ENV["admin_password"]
  end
end

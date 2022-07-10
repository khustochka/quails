# frozen_string_literal: true

module Quails
  module CredentialsCheck
    class << self
      def check_credentials(username, password)
        match_username(username) && match_password(password)
      end

      def configure
        __configure(ENV["QUAILS_ADMIN_USERNAME"], ENV["QUAILS_ADMIN_PASSWORD"])
      end

      private

      def __configure(username, password)
        @__username = username
        @__password = password
        true
      end

      def match_username(username)
        username == @__username
      end

      def match_password(password)
        real_match_password(password) || test_match_password(password)
      end

      def real_match_password(password)
        BCrypt::Password.valid_hash?(@__password) && BCrypt::Password.new(@__password).is_password?(password)
      end

      def test_match_password(password)
        (Rails.env.test? || Rails.env.development?) && password == @__password
      end
    end
  end
end

# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      session = request.session
      if session[:admin] == true
        "admin"
      else
        reject_unauthorized_connection
      end
    end
  end
end

# frozen_string_literal: true

class APIController < ActionController::Base # rubocop:disable Rails/ApplicationController
  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      # Compare the tokens in a time-constant manner, to mitigate
      # timing attacks.
      if ActiveSupport::SecurityUtils.secure_compare(token, ENV["API_TOKEN"])
        true
      else
        render json: { status: 401, message: "unauthorized" }, status: :unauthorized
      end
    end
  end
end

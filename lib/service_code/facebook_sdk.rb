# frozen_string_literal: true

require 'service_code/service_code'

class FacebookSdk < ServiceCode

  CODE_ENV_VAR = -"quails_facebook_app_id"

  def render
    unless Rails.env.test? || config.code.blank?
      @view.render partial: 'social/fb_sdk', object: config.code, as: :code
    end
  end

end

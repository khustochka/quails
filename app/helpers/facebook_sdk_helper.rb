# frozen_string_literal: true

module FacebookSdkHelper
  def facebook_app_id
    @@facebook_app_id ||= ENV["quails_facebook_app_id"]
  end
end

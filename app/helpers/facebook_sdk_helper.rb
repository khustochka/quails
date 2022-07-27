# frozen_string_literal: true

module FacebookSdkHelper
  mattr_accessor :facebook_app_id

  def facebook_app_id
    FacebookSdkHelper.facebook_app_id ||= ENV["quails_facebook_app_id"]
  end
end

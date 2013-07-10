require 'service_code/service_code'

class FacebookSdk < ServiceCode

  def render
    cache :facebook_sdk do
      unless Rails.env.test? || config.code.blank?
        @view.render partial: 'facebook/sdk', object: config.code, as: :code
      end
    end
  end

end

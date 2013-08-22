require 'service_code/service_code'

class VkontakteSdk < ServiceCode

  def render
    cache :vkontakte_sdk do
      unless Rails.env.test? || config.code.blank?
        @view.render partial: 'social/vk_sdk', object: config.code, as: :code
      end
    end
  end

end

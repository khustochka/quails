require 'service_code/service_code'

class GoogleSearch < ServiceCode

  def render
    cache :google_cse do
      unless Rails.env.test? || config.code.blank?
        @view.render partial: 'partials/search', object: config.code, as: :code
      end
    end
  end

end

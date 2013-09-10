require 'service_code/service_code'

class GoogleSearch < ServiceCode

  def render
    unless Rails.env.test? || config.code.blank?
      @view.render partial: 'partials/search', object: config.code, as: :code
    end
  end

end

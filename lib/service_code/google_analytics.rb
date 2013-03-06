require 'service_code/service_code'

class GoogleAnalytics < ServiceCode

  def render
    cache [:ga_code, admin: @view.admin_layout?] do
      unless !(Rails.env.production? && Quails.env.real_prod?) || @view.admin_layout? || @@code.blank?
        @view.render partial: 'partials/ga_code', object: @@code, as: :code
      end
    end
  end

end

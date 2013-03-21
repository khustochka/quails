require 'service_code/service_code'

class GoogleAnalytics < ServiceCode

  def render
    cache [:ga_code, admin: may_be_admin?] do
      unless !(Rails.env.production? && Quails.env.real_prod?) || may_be_admin? || config.code.blank?
        @view.render partial: 'partials/ga_code', object: config.code, as: :code
      end
    end
  end

  private
  def may_be_admin?
    @view.current_user.has_admin_cookie? || @view.admin_layout?
  end

end

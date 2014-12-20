require 'service_code/service_code'

class Birdingtop < ServiceCode

  CODE_ENV_VAR = 'quails_birdingtop_code'.freeze

  def render
    cache [:birdingtop_code, admin: is_admin?] do
      unless !(Rails.env.production? && Quails.env.real_prod?) || is_admin? || config.code.blank?
        @view.render partial: 'partials/birdingtop_code', object: config.code, as: :code
      end
    end
  end

end

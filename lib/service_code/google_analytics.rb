# frozen_string_literal: true

require 'service_code/service_code'

class GoogleAnalytics < ServiceCode

  CODE_ENV_VAR = -"quails_ga_code"

  def render
    cache [:ga_code, admin: may_be_admin?] do
      unless !(Rails.env.production? && Quails.env.real_prod?) || may_be_admin? || config.code.blank?
        @view.render partial: 'partials/ga_code', object: config.code, as: :code
      end
    end
  end

end

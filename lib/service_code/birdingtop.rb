# frozen_string_literal: true

require "service_code/service_code"

class Birdingtop < ServiceCode

  CODE_ENV_VAR = -"quails_birdingtop_code"

  def render
    cache [:birdingtop_code, show: is_admin? || map?] do
      unless is_admin? || config.code.blank? || map?
        if Rails.env.production? && Quails.env.real_prod?
          @view.render partial: "partials/birdingtop_code", object: config.code, as: :code
        else
          @view.content_tag(:span, "Here be BirdingTop banner.")
        end
      end
    end
  end

  private

  def map?
    @view.controller_name == "maps"
  end

end

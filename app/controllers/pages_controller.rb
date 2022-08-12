class PagesController < ApplicationController
  include HighVoltage::StaticPage

  # Regular `localized` does not work, because of the same action
  before_action only: [:show] do
    @localized = true
    @all_locales = case params[:id]
    when "winter" then [] # Means it has locale, but not translated
    when "links" then [:uk, :ru]
    when "about" then I18n.available_locales
    else I18n.available_locales
    end
  end
end

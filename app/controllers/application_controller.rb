class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  before_filter :set_locale

  private
  def set_locale
    @all_locales = %w(en ru uk)
    @locale = I18n.locale = non_default_locales.include?(params[:locale]) ? params[:locale] : I18n.default_locale
#    I18n.reload!
  end

  def default_url_options(options={})
    { :locale => I18n.locale } if non_default_locales.include?(I18n.locale)
  end

  def non_default_locales
    @all_locales - [I18n.default_locale.to_s]
  end
end

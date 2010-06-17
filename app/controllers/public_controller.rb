class PublicController < ApplicationController
  layout 'public'

  before_filter :set_locale

  private
  def set_locale
    @all_locales = %w(en ru uk)
    @locale = I18n.locale = non_default_locales.include?(params[:locale]) ? params[:locale] : I18n.default_locale
#    I18n.reload!
  end

  def default_url_options(options={})
    options.merge non_default_locales.include?(I18n.locale) ? { :locale => I18n.locale } : {}
  end

  def non_default_locales
    @all_locales - [I18n.default_locale.to_s]
  end
end
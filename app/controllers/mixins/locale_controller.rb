$localedisabled = true

module LocaleController
  def self.included(klass)
    klass.before_filter :set_locale
  end

  private
  def set_locale
    I18n.locale = params[:hl] || DEFAULT_PUBLIC_LOCALE
    #@locale = I18n.locale = non_default_locales.include?(params[:locale]) ? params[:locale] : I18n.default_locale
#    I18n.reload!
  end

  def default_url_options(options={})
    options.merge params[:hl] ? {:hl => params[:hl]} : {}
  end
end

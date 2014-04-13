module LocaleController
  def self.included(klass)
    klass.before_filter :set_locale
  end

  private
  def set_locale
    locale_from_path = request.symbolized_path_parameters[:locale].try(:to_sym)
    if locale_from_path && ALL_LOCALES.include?(locale_from_path)
      @locale_set = I18n.locale = locale_from_path
    else
      I18n.locale = I18n.default_locale
    end
  end

  def default_url_options(options={})
    options.delete(:locale)
    locale_option = @locale_set ? {locale: @locale_set} : {}
    options.merge(locale_option)
  end
end

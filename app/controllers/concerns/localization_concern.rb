module LocalizationConcern
  def self.included(klass)
    klass.before_action :set_locale
  end

  private

  def set_locale
    locale_from_path = request.path_parameters[:locale].try(:to_sym)
    I18n.locale = if locale_from_path && ALL_LOCALES.include?(locale_from_path)
                    locale_from_path
                  else
                    I18n.default_locale
                  end
  end

  def default_url_options(options = {})
    new_opts = options
    new_opts.delete(:locale)
    new_opts[:locale] = I18n.locale unless I18n.default_locale?
    new_opts
  end
end


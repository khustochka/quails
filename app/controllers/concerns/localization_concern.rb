# frozen_string_literal: true

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
end

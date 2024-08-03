# frozen_string_literal: true

module LocaleHelper
  BLOGLESS_LOCALES = [:en]
  CYRILLIC_LOCALES = [:uk, :ru]

  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def russian_locale?
    I18n.locale == :ru
  end

  def cyrillic_locale?
    I18n.locale.in?(CYRILLIC_LOCALES)
  end

  def blogless_locale?
    I18n.locale.in?(BLOGLESS_LOCALES)
  end
end

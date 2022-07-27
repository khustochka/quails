# frozen_string_literal: true

module LocaleHelper
  BLOGLESS_LOCALES = [:en]

  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def russian_locale?
    I18n.locale == :ru
  end

  def cyrillic_locale?
    I18n.locale.in?(%w(uk ru))
  end

  def blogless_locale?
    I18n.locale.in?(BLOGLESS_LOCALES)
  end
end

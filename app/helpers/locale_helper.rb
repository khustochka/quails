# frozen_string_literal: true

module LocaleHelper
  # English is not blogless, but we do not show links to posts on Lifelist and Species pages
  # in English locale, because it is implemented in a hacky way.
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

  def locale_prefix(locale)
    if locale == I18n.default_locale
      nil
    else
      locale.to_s
    end
  end
end

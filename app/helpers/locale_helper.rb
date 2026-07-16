# frozen_string_literal: true

module LocaleHelper
  # English is not blogless, but we do not show links to posts on Lifelist and Species pages
  # in English locale, because it is implemented in a hacky way.
  BLOGLESS_LOCALES = [:en]
  CYRILLIC_LOCALES = [:uk, :ru]

  NAMING_LOCALE_PRIORITY = [:en, :uk, :ru]

  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def russian_locale?
    I18n.locale == :ru
  end

  def cyrillic_locale?
    I18n.locale.in?(CYRILLIC_LOCALES)
  end

  def hidden_locale?
    I18n.locale.in?(Quails.hidden_locales)
  end

  # For hidden locales the canonical always points to the same page under the
  # default locale (same URL with the locale prefix stripped), overriding any
  # view-provided @canonical.
  def canonical_url
    return @canonical unless hidden_locale?

    path = request.fullpath.sub(%r{\A/#{I18n.locale}(?=[/?]|\z)}, "")
    path = "/#{path}" unless path.start_with?("/")
    request.base_url + path
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

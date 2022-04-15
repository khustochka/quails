# frozen_string_literal: true

module LocaleHelper
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
    I18n.locale == :en
  end
end

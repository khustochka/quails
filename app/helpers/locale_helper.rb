# frozen_string_literal: true
module LocaleHelper
  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def russian_locale?
    I18n.locale == :ru
  end
end

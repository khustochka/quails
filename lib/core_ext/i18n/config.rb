# frozen_string_literal: true

module I18n
  class Config

    def default_locale?
      locale == DEFAULT_PUBLIC_LOCALE
    end

    def russian_locale?
      locale == :ru
    end

  end
end

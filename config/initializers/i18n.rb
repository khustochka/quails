ALL_LOCALES = [:en, :ru, :uk]
DEFAULT_PUBLIC_LOCALE = :ru

I18n.available_locales = ALL_LOCALES

if Rails.env.development? || Rails.env.test?

  # raises exception when translation is missing
  module I18n
    class JustRaiseHandler < ExceptionHandler
      def call(exception, locale, key, options)
        if exception.is_a?(MissingTranslation) && key.to_s != 'i18n.plural.rule'
          raise exception.to_exception
        else
          super
        end
      end
    end
  end

 I18n.exception_handler = I18n::JustRaiseHandler.new

end
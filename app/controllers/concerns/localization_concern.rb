# frozen_string_literal: true

module LocalizationConcern
  def self.included(klass)
    klass.extend ClassMethods
    klass.before_action :set_locale
    klass.helper_method :localized?, :other_locales
  end

  module ClassMethods

    # Use `locales: []` if you want to extract locale from params, but there are no translations.
    def localized(options = {})
      opts = options.dup.symbolize_keys!
      locales = opts.delete(:locales)
      before_action(opts) do
        @localized = true
        @all_locales = locales || I18n.available_locales
      end
    end
  end

  private

  def set_locale
    locale_from_path = request.path_parameters[:locale].try(:to_sym)
    I18n.locale = if locale_from_path && I18n.available_locales.include?(locale_from_path)
      locale_from_path
    else
      I18n.default_locale
    end
  end

  def localized?
    @localized
  end

  def other_locales
    all_locales.delete(I18n.locale).to_a
  end

  def all_locales
    @calc_all_locales ||= Set.new(@all_locales)
  end
end
